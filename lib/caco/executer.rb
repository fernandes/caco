module Caco
  class Executer < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:command)
    step Caco::Macro::NormalizeParams()
    step :execute!

    def execute!(ctx, command:, **)
      s, e, o = self.class.send(:execute, command)
      ctx[:signal] = [s, e, o]
      ctx[:exit_code] = e
      ctx[:output] = o

      return s
    end

    module ClassMethods
      private
      def execute(command)
        out = nil
        pid = nil
        exit_status = nil
        Open3.popen3(*command) do |i, o, e, t|
          pid = t.pid
          out = o.read
          exit_status = t.value
        end
        return exit_status.success?, exit_status.exitstatus, out
      end
    end
    extend ClassMethods
  end
end
