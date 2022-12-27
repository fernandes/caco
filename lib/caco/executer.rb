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
      output = self.class.send(:execute, command)
      s = output.success?
      e = output.exit_status
      o = output.stdout
      error = output.stderr
      ctx[:signal] = [s, e, o, error]
      ctx[:exit_code] = e
      ctx[:output] = o
      ctx[:stderr] = error

      return s
    end

    module ClassMethods
      extend T::Sig

      private
      sig {params(command: T.any(String,T::Array[String])).returns(Executer::Output)}
      def execute(command)
        Open3.popen3(*command) do |i, o, e, t|
          exit_status = t.value
          Executer::Output.new(
            success: exit_status.success?,
            exit_status: exit_status.exitstatus,
            stdout: o.read,
            stderr: e.read
          )
        end
      end
    end
    extend ClassMethods
  end
end
