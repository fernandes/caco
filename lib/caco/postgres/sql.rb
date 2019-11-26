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
      ctx[:sql_command] = "su -l -c \"psql -e -U postgres -d postgres <<EOF
      #{sql}
      EOF
      \" postgres"
      # ctx[:sql_command] = "psql -U fernandes -d postgres -c \"#{sql}\""
    end

    def shell_input(original_ctx, sql_command:, **)
      { params: { command: sql_command } }
    end
  
    def shell_output(scoped_ctx, exit_code:, output:, stderr:, **)
      { exit_code: exit_code, output: output, stderr: stderr }
    end
  end
end
