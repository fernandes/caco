# typed: true

require "caco/resource/base"
module Caco::Resource
  class Execute < Caco::Resource::Base
    extend T::Sig

    LOG_FILE = ENV.fetch("CACO_LOG_FILE", "/var/log/caco.log")

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
    attr_accessor :stream_output

    sig { override.void }
    def make_absent
    end

    sig { override.void }
    def make_present
      command_to_execute = command.present? ? command : name
      if user
        command_to_execute = "runuser -l #{user} -c '#{command_to_execute}'"
      end
      output = self.class.send(:execute, command_to_execute, cwd: cwd, stream_output: stream_output)
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

      sig {
        params(
          command: T.any(String, T::Array[String]),
          cwd: T.nilable(String),
          stream_output: T.nilable(T.proc.params(key: Symbol, line: String).void)
        )
          .returns(Caco::Resource::Execute::Output)
      }
      def execute(command, cwd: nil, stream_output: nil)
        log_file = Caco.config.log_file

        output = Caco::Resource::Execute::Output.new(success: false, exit_status: 0, stdout: "")
        params = {}
        params.merge!(chdir: cwd) if cwd

        ::File.write(log_file, "Running command on #{cwd}: \n #{command}", mode: "a")
        Open3.popen3(*command, **params) do |i, o, e, t|
          if stream_output
            {stdout: o, stderr: e}.each do |key, stream|
              Thread.new do
                until (line = stream.gets).nil?
                  stream_output.call(key, line)
                end
              rescue IOError
              end
            end

            t.join # don't exit until the external process is done
          end

          process_command(output, i, o, e, t)
        end

        ::File.write(log_file, "[out] #{output.stdout}", mode: "a")
        ::File.write(log_file, "[err] #{output.stdout}", mode: "a")
        output
      end

      def process_command(output, i, o, e, t)
        exit_status = T.cast(t.value, Process::Status)
        output.success = T.must(exit_status.success?)
        output.exit_status = T.must(exit_status.exitstatus)
        output.stdout = o.read
        output.stderr = e.read
      end
    end
    extend ClassMethods
  end
end
