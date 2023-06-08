# frozen_string_literal: true

# Caco Module
module Caco
  extend T::Sig

  # Nodenv Module
  module Nodenv
    module Cell
      # Cell containg the bash profile content
      class Profile < Trailblazer::Cell
        self.view_paths = [File.expand_path('../', __dir__)]
      end
    end

    def self.install
      clone_repo
      write_profile_file
    end

    def self.repo_exist?
      File.exist?('/opt/nodenv')
    end

    def self.clone_repo
      return true if repo_exist?

      Caco.execute('clone nodenv repo', command: 'git clone https://github.com/nodenv/nodenv.git /opt/nodenv')
    end

    def self.write_profile_file
      profile_content = Caco::Nodenv::Cell::Profile.call.to_s
      Caco.file '/etc/profile.d/nodenv.sh', content: profile_content
    end

    def self.version_installed?(version)
      has_version = nodenv_command(
        "nodenv_version_installed? #{version}",
        command: "nodenv versions|egrep -q \"#{version}\""
      )
      has_version.success?
    end

    def self.install_version(version)
      return true if version_installed?(version)

      result = nodenv_command("nodenv_install_version #{version}", command: "nodenv install #{version}")
      result.success?
    end

    def self.global_version
      result = nodenv_command('nodenv_global_version', command: 'nodenv global')
      result.output.chomp!
    end

    def self.global_version=(version)
      return true if global_version == version

      result = nodenv_command("nodenv_set_global_version #{version}", command: "nodenv global #{version}")
      result.success?
    end

    def self.nodenv_command(name, command:)
      Caco.execute name, command: <<~CMD
        export PATH="/opt/nodenv/bin:${PATH}" ;
        export NODENV_ROOT="/opt/nodenv" ;
        eval "$(nodenv init -)";
        #{command}
      CMD
    end

    def self.install_node_build
      return true if File.exist?('/opt/nodenv/plugin/node-build')

      Caco.execute(
        'clone node-build repo',
        command: 'git clone https://github.com/nodenv/node-build.git /opt/nodenv/plugins/node-build'
      )
    end

    def self.install_nodenv_each
      return true if File.exist?('/opt/nodenv/plugin/nodenv-each')

      Caco.execute(
        'clone nodenv-each repo',
        command: 'git clone https://github.com/nodenv/nodenv-each.git /opt/nodenv/plugins/nodenv-each'
      )
    end

    def self.install_nodenv_default_packages
      unless File.exist?('/opt/nodenv/plugins/nodenv-default-packages')
        Caco.execute(
          'clone nodenv-default-packages repo',
          command: <<~COMMAND
            git clone https://github.com/nodenv/nodenv-default-packages.git /opt/nodenv/plugins/nodenv-default-packages
          COMMAND
        )
      end

      Caco.file '/opt/nodenv/default-packages', content: <<~GEMS
        yarn
      GEMS
    end

    def self.update_node_build
      Caco.execute(
        'update node-build repo',
        command: 'git -C /opt/nodenv/plugins/node-build pull'
      )
    end
  end
end

