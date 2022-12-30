# typed: false
module Caco
  class Executer < Trailblazer::Operation
    class Output < T::Struct
      prop :success, T::Boolean
      prop :exit_status, Integer
      prop :stdout, String
      prop :stderr, T.nilable(String)

      def success?
        success
      end
    end

    step :execute!

    def execute!(ctx, command:, **kwargs)
      result = execute(command)
      ctx[:signal] = result[:signal]
      ctx[:exit_code] = result[:exit_code]
      ctx[:output] = result[:output]
      ctx[:stderr] = result[:stderr]

      return ctx[:signal].first
    end
  end
end
