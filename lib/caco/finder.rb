module Caco::Finder
  module ClassMethods
    def call(command:, regexp:)
      output = execute_command(command)
      output.freeze.match?(regexp)
    end

    private
      def execute_command(command)
        s, e, o = Caco::Executer.(command: command)
        o
      end
  end

  extend ClassMethods
end
