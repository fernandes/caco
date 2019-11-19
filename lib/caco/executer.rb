module Caco
  class Executer
    module ClassMethods
      @@stubbing = false
      @@semaphore = Mutex.new

      def call(command:)
        return *@@return if @@stubbing

        execute(command)
      end

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
