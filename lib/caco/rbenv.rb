# frozen_string_literal: true
# typed: strict

module Caco::Rbenv
  # @@root = "/opt/rbenv"
  mattr_accessor :root

  extend T::Sig

  PACKAGES_TO_INSTALL = T.let({
    'stretch': %w[
      git autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev
      libffi-dev libgdbm3 libgdbm-dev
    ],
    'buster': %w[
      git autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev
      libncurses5-dev libffi-dev libgdbm6 libgdbm-dev
    ],
    'bullseye': %w[
      autoconf bison patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev
      zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
    ]
  }.freeze, T::Hash[Symbol, T::Array[String]])

  sig { returns(Caco::Resource::Result) }
  def self.install
    install_dependencies
    clone_repo
    write_profile_file
  end

  sig { returns(T::Boolean) }
  def self.repo_exist?
    File.exist?(install_to)
  end

  sig { returns(T::Boolean) }
  def self.clone_repo
    return true if repo_exist?

    Caco.execute('clone rbenv repo', command: "git clone https://github.com/rbenv/rbenv.git #{install_to}").success?
  end

  sig { returns(Caco::Resource::Result) }
  def self.write_profile_file
    profile_content = Caco::Rbenv::Cell::Profile.call.to_s
    Caco.file '/etc/profile.d/rbenv.sh', content: profile_content
  end

  sig { params(version: String).returns(T::Boolean) }
  def self.version_installed?(version)
    has_version = rbenv_command(
      "rbenv_version_installed? #{version}",
      command: "rbenv versions|egrep -q \"#{version}\""
    )
    has_version.success?
  end

  sig { params(version: String).returns(T::Boolean) }
  def self.install_version(version)
    return true if version_installed?(version)

    result = rbenv_command("rbenv_install_version #{version}", command: "rbenv install #{version}")
    result.success?
  end

  sig { returns(String) }
  def self.global_version
    result = rbenv_command('rbenv_global_version', command: 'rbenv global')
    T.cast(T.cast(result.output, String).chomp!, String)
  end

  sig { params(version: String).returns(T::Boolean) }
  def self.global_version=(version)
    return true if global_version == version

    result = rbenv_command("rbenv_set_global_version #{version}", command: "rbenv global #{version}")
    result.success?
  end

  sig { params(name: String, command: String).returns(Caco::Resource::Result) }
  def self.rbenv_command(name, command:)
    Caco.execute name, command: <<~CMD
      export PATH="#{install_to}/bin:${PATH}" ;
      export RBENV_ROOT="#{install_to}" ;
      eval "$(rbenv init -)";
      #{command}
    CMD
  end

  sig { returns(T.any(TrueClass, Caco::Resource::Result)) }
  def self.install_ruby_build
    return true if File.exist?("#{install_to}/plugin/ruby-build")

    Caco.execute(
      'clone ruby-build repo',
      command: "git clone https://github.com/rbenv/ruby-build.git #{install_to}/plugins/ruby-build"
    )
  end

  sig { returns(T.any(TrueClass, Caco::Resource::Result)) }
  def self.install_rbenv_each
    return true if File.exist?("#{install_to}/plugin/rbenv-each")

    Caco.execute(
      'clone rbenv-each repo',
      command: "git clone https://github.com/rbenv/rbenv-each.git #{install_to}/plugins/rbenv-each"
    )
  end

  sig { returns(T::Boolean) }
  def self.install_rbenv_default_gems
    unless File.exist?("#{install_to}/plugins/rbenv-default-gems")
      Caco.execute(
        'clone rbenv-default-gems repo',
        command: "git clone https://github.com/rbenv/rbenv-default-gems.git #{install_to}/plugins/rbenv-default-gems"
      )
    end

    Caco.file "#{install_to}/default-gems", content: <<~GEMS
      bundler
      foreman
      tmuxinator
      mina
    GEMS

    true
  end

  sig { returns(Caco::Resource::Result) }
  def self.update_ruby_build
    Caco.execute(
      'update ruby-build repo',
      command: "git -C #{install_to}/plugins/ruby-build pull"
    )
  end

  sig { params(distro_name: Symbol).returns(T::Array[String]) }
  def self.packages_to_install(distro_name)
    PACKAGES_TO_INSTALL.fetch(distro_name, [])
  end

  sig { returns(T::Array[String]) }
  def self.install_dependencies
    distro_name = Caco::Facter.call('os', 'distro', 'codename')
    packages_to_install(distro_name.to_sym).each do |package|
      Caco.package package
    end
  end

  sig { returns(String) }
  def self.install_to
    root || '/opt/rbenv'
  end
end
