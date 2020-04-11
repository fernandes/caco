module Caco
  class Executer < Trailblazer::Operation
    step :execute!

    def execute!(ctx, command:, **)
      s, e, o, error = self.class.send(:execute, command)
      ctx[:signal] = [s, e, o, error]
      ctx[:exit_code] = e
      ctx[:output] = o
      ctx[:stderr] = error

      return s
    end

    module ClassMethods
      private
      def execute(command)
        stdout = nil
        stderr = nil
        pid = nil
        exit_status = nil
        Open3.popen3(*command) do |i, o, e, t|
          pid = t.pid
          stdout = o.read
          stderr = e.read
          exit_status = t.value
        end
        return exit_status.success?, exit_status.exitstatus, stdout, stderr
      end
    end
    extend ClassMethods
  end
end
