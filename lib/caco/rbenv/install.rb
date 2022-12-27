module Caco::Rbenv
  class Install < Trailblazer::Operation
    CloneRepo = Class.new(Trailblazer::Activity::Signal)

    step :install_packages!
    step :repo_exist?, Output(CloneRepo, :clone_repo) => Path(connect_to: Id(:make_src)) do
      step :clone_repo
    end

    pass Subprocess(Class.new(Caco::Executer)),
      input: ->(_ctx, **) {{
        command: "[ ! -f /opt/rbenv/libexec/rbenv-realpath.dylib ] && cd /opt/rbenv && src/configure && make -C src; true",
      }},
      Output(:failure) => Track(:success),
      id: :make_src

    step ->(ctx, **) {
        ctx[:profile_content] = Caco::Rbenv::Cell::Profile.().to_s
      },
      id: :build_profile_content

    step :write_file,
      input: ->(_ctx, profile_content:, **) {{
        path: "/etc/profile.d/rbenv.sh",
        content: profile_content
      }}

    def write_file(ctx, path:, content:, **)
      result = file path, content: content
    end

    def install_packages!(ctx, **)
      packages = []
      if Caco::Facter.("os", "distro", "codename") == "stretch"
        packages = %w(git autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev)
      elsif Caco::Facter.("os", "distro", "codename") == "buster"
        packages = %w(git autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev)
      end

      packages.each do |package|
        result = Caco::Debian::PackageInstall.(package: package)
        return false if result.failure?
      end
      true
    end

    def repo_exist?(ctx, **)
      self.class.repo_exist?
    end

    def self.repo_exist?
      File.exist?("/opt/rbenv") ? true : CloneRepo
    end

    def clone_repo(ctx, **)
      result = Caco::Executer.(command: "git clone https://github.com/rbenv/rbenv.git /opt/rbenv")
      result.success?
    end
  end
end
