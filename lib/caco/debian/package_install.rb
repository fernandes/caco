module Caco::Debian
  class PackageInstall < Trailblazer::Operation
    class PackageNameError < StandardError; end

    step Subprocess(Caco::Debian::PackageInstalled),
      id: "package_installed?",
      input: [:package],
      output: []

    fail Subprocess(Caco::Executer),
      Output(:success) => End(:success),
      input: ->(_ctx, package:, **) {{
        command: "apt-get install -y #{package}"
      }},
      output: { exit_code: :package_install_exit_code, output: :package_install_output },
      id: "package_install"

    step ->(ctx, **) { ctx[:already_installed] = true },
      id: :package_already_installed!
  end
end
