module Caco::Postgres
  class Sql < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:sql)
    step Caco::Macro::NormalizeParams()
    step :build_command
    step Subprocess(Caco::Executer),
      input: :shell_input,
      output: :shell_output,
      id: "shell"
    
    def build_command(ctx, sql:, **)
      ctx[:sql_command] = "su -c \"psql -d postgres -c '#{sql}'\" postgres"
    end

    def shell_input(original_ctx, sql_command:, **)
      { params: { command: sql_command } }
    end
  
    def shell_output(scoped_ctx, exit_code:, output:, **)
      { exit_code: exit_code, output: output }
    end
  end
end
