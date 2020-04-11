module Caco::Postgres
  class Sql < Trailblazer::Operation
    step :build_command
    step Subprocess(Caco::Executer),
      input: { sql_command: :command },
      output: [:exit_code, :output, :stderr],
      id: "shell"

    def build_command(ctx, sql:, **)
      ctx[:sql_command] = "su -l -c \"psql -e -U postgres -d postgres <<EOF
      #{sql}
      EOF
      \" postgres"
      # ctx[:sql_command] = "psql -U fernandes -d postgres -c \"#{sql}\""
    end
  end
end
