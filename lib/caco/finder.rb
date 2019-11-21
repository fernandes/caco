module Caco
  class Finder < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:command)
    step Caco::Macro::ValidateParamPresence(:regexp)
    step Caco::Macro::NormalizeParams()
    step Subprocess(Caco::Executer),
      input: :execute_command_input,
      output: :execute_command_output,
      id: "execute_command"
    step :match_regexp

    def match_regexp(ctx, command_output:, regexp:, **)
      command_output.freeze.match?(regexp)
    end

    private
      def execute_command_input(original_ctx, command:, **)
        { params: { command: command } }
      end
    
      def execute_command_output(scoped_ctx, exit_code:, output:, **)
        { command_exit_code: exit_code, command_output: output }
      end
  end
end
