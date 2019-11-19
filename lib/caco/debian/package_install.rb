module Caco::Debian
  class PackageInstall < Trailblazer::Operation
    class PackageNameError < StandardError; end

    step :check_package_name
    step :check_needs_install, Output(Trailblazer::Activity::Left, :failure) => End(:success)
    step :package_install

    def check_package_name(ctx, params:, **)
      raise PackageNameError.new("Provide a package name") if params[:package].empty?
      true
    end

    def check_needs_install(ctx, params:, **)
      ctx[:package_needs_install] = !Caco::Debian::PackageInstalled.(package: params[:package])
    end

    def package_install(ctx, params:, **)
      package = params[:package]

      success, exit_code, output = Caco::Executer.(command: "apt-get install -y #{package}")
      ctx[:package_installed] = success
    end
  end
end
