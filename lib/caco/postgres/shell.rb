module Caco::Postgres
  class Shell < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:command)
    step Caco::Macro::NormalizeParams()
    step :build_command
    step Subprocess(Caco::Executer),
      input: :shell_input,
      output: :shell_output,
      id: "shell"
    
    def build_command(ctx, command:, **)
      ctx[:shell_command] = "su -c \"#{command}\" postgres"
    end

    def shell_input(original_ctx, shell_command:, **)
      { params: { command: shell_command } }
    end
  
    def shell_output(scoped_ctx, exit_code:, output:, **)
      { exit_code: exit_code, output: output }
    end
  end
end
