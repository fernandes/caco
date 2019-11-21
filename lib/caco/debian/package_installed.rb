module Caco::Debian
  class PackageInstalled < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:package)
    step Caco::Macro::NormalizeParams()

    step Subprocess(Caco::Executer),
      input: :dpkg_input,
      output: :dpkg_output,
      id: "dpkg"
    step Subprocess(Caco::Finder),
      input: :dpkg_query_input,
      id: "dpkg_query"

    private
      def dpkg_input(original_ctx, package:, **)
        { params: { command: "dpkg -s #{package}" } }
      end
    
      def dpkg_output(scoped_ctx, exit_code:, output:, **)
        { command_exit_code: exit_code, command_output: output }
      end

      def dpkg_query_input(original_ctx, package:, **)
        { params: { command: "dpkg-query -W -f='${Status} ${Version}\n' #{package}", regexp: /^install/ } }
      end
  end
end
