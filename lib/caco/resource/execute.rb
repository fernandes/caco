# typed: true
require "caco/resource/base"
module Caco::Resource
  class Execute < Caco::Resource::Base
    extend T::Sig

    class Output < T::Struct
      prop :success, T::Boolean
      prop :exit_status, Integer
      prop :stdout, String
      prop :stderr, T.nilable(String)

      def success?
        success
      end
    end

    attr_accessor :command
    attr_accessor :user
    attr_accessor :cwd

    sig { override.void }
    def make_absent
    end

    sig { override.void }
    def make_present
      command_to_execute = command.present? ? command : name
      if user
        command_to_execute = "runuser -u #{user} -- #{command_to_execute}"
      end
      output = self.class.send(:execute, command_to_execute, cwd: cwd)
      s = output.success?
      e = output.exit_status
      o = output.stdout
      error = output.stderr

      @signal = [s, e, o, error]
      @exit_code = e
      @output = o
      @stderr = error
    end

    def resource_attributes
      {
        signal: @signal,
        exit_code: @exit_code,
        output: @output,
        stderr: @stderr
      }
    end

    module ClassMethods
      extend T::Sig

      private
      sig {params(command: T.any(String,T::Array[String]), cwd: T.nilable(String)).returns(Caco::Resource::Execute::Output)}
      def execute(command, cwd: nil)
        chdir = cwd.nil? ? '/root' : cwd
        Open3.popen3(command, :chdir => chdir) do |i, o, e, t|
          exit_status = t.value
          Caco::Resource::Execute::Output.new(
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


