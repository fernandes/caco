module Caco
  class Finder < Trailblazer::Operation
    step Subprocess(Caco::Executer),
      input: [:command],
      output: { exit_code: :command_exit_code, output: :command_output },
      id: "execute_command"

    step ->(ctx, command_output:, regexp:, **) {
        command_output.freeze.match?(regexp)  
      },
      id: :match_regexp
  end
end
