module Caco::Debian
  class PackageInstall < Trailblazer::Operation
    class PackageNameError < StandardError; end
    step Caco::Macro::ValidateParamPresence(:package)
    step Caco::Macro::NormalizeParams()

    step Subprocess(Caco::Debian::PackageInstalled),
      id: "package_installed?",
      input: :package_installed_input,
      output: []
    fail Subprocess(Caco::Executer),
      input: :package_install_input,
      output: :package_install_output,
      id: "package_install",
      Output(:success) => End(:success)
    step :package_already_installed!

    def package_already_installed!(ctx, params:, **)
      ctx[:already_installed] = true
    end

    private
      def package_installed_input(original_ctx, package:, **)
        { params: { package: package } }
      end

      def package_install_input(original_ctx, package:, **)
        { params: { command: "apt-get install -y #{package}" } }
      end
    
      def package_install_output(scoped_ctx, exit_code:, output:, **)
        { package_install_exit_code: exit_code, package_install_output: output }
      end
  end
end
