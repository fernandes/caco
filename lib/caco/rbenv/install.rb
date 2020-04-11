module Caco::Rbenv
  class Install < Trailblazer::Operation
    step :install_packages!
    step :repo_exist?, Output(Trailblazer::Activity::Left, :failure) => Path(connect_to: Id(:make_src)) do
      step :clone_repo
    end

    pass Subprocess(Class.new(Caco::Executer)),
      input:  ->(_ctx, **) do { params: {
        command: "[ ! -f /opt/rbenv/libexec/rbenv-realpath.dylib ] && cd /opt/rbenv && src/configure && make -C src",
      } } end,
      id: :make_src
    step :build_profile_content
    step Subprocess(Caco::FileWriter),
      input:  ->(_ctx, profile_content:, **) do { params: {
        path: "/etc/profile.d/rbenv.sh",
        content: profile_content
      } } end

    def install_packages!(ctx, **)
      packages = []
      if Caco::Facter.("os", "distro", "codename") == "stretch"
        packages = %w(git autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev)
      elsif Caco::Facter.("os", "distro", "codename") == "buster"
        packages = %w(git autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev)
      end

      packages.each do |package|
        result = Caco::Debian::PackageInstall.({params: {package: package}})
        return false if result.failure?
      end
      true
    end

    def clone_repo(ctx, **)
      result = Caco::Executer.(params: { command: "git clone https://github.com/rbenv/rbenv.git /opt/rbenv" })
      result.success?
    end

    def repo_exist?(ctx, **)
      self.class.repo_exist?
    end

    def build_profile_content(ctx, **)
      content = ctx[:profile_content] = Caco::Rbenv::Cell::Profile.().to_s
    end

    module ClassMethods
      def repo_exist?
        File.exist?("/opt/rbenv")
      end
    end
    extend ClassMethods
  end
end
