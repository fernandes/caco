module Caco::Postgres
  class Shell < Trailblazer::Operation
    step ->(ctx, command:, **) {
        ctx[:shell_command] = "su -c \"#{command}\" postgres"
      },
      id: :build_command

    step Subprocess(Caco::Executer),
      input: { shell_command: :command },
      output: [:exit_code, :output],
      id: "shell"
  end
end
