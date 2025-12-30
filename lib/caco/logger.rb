# typed: true
module Caco
  class Logger
    extend T::Sig

    COLORS = {
      reset: "\e[0m",
      bold: "\e[1m",
      dim: "\e[2m",
      green: "\e[32m",
      yellow: "\e[33m",
      blue: "\e[34m",
      magenta: "\e[35m",
      cyan: "\e[36m",
      gray: "\e[90m"
    }.freeze

    class << self
      extend T::Sig

      sig { params(resource: String, name: String).void }
      def start(resource, name)
        @start_time = Time.now
        @current_resource = resource
        @current_name = name
        print "#{timestamp} #{color(:cyan)}#{resource}#{color(:reset)} "
        print "#{color(:bold)}#{name}#{color(:reset)} "
        $stdout.flush
      end

      sig { params(changed: T::Boolean).void }
      def finish(changed: false)
        elapsed = @start_time ? Time.now - @start_time : 0
        status = changed ? "#{color(:green)}changed" : "#{color(:gray)}ok"
        puts "#{status}#{color(:reset)} #{color(:dim)}(#{format_duration(elapsed)})#{color(:reset)}"

        # Log to file
        file_status = changed ? "changed" : "ok"
        log_to_file("[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] #{@current_resource} #{@current_name} #{file_status} (#{format_duration(elapsed)})")
      end

      sig { params(message: String).void }
      def info(message)
        puts "#{timestamp} #{color(:blue)}info#{color(:reset)} #{message}"
        log_to_file("[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] INFO #{message}")
      end

      sig { params(message: String).void }
      def warn(message)
        puts "#{timestamp} #{color(:yellow)}warn#{color(:reset)} #{message}"
        log_to_file("[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] WARN #{message}")
      end

      sig { params(message: String).void }
      def error(message)
        puts "#{timestamp} #{color(:magenta)}error#{color(:reset)} #{message}"
        log_to_file("[#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}] ERROR #{message}")
      end

      sig { params(command: String).void }
      def command(command)
        @current_command = command
        # Truncate long commands for display
        display_cmd = command.length > 60 ? "#{command[0..57]}..." : command
        print "#{color(:dim)}$ #{display_cmd}#{color(:reset)} "
        $stdout.flush
      end

      sig { params(stdout: String, stderr: T.nilable(String), exit_code: Integer).void }
      def command_result(stdout:, stderr:, exit_code:)
        return unless @current_command

        log_to_file("  $ #{@current_command}")
        log_to_file("  exit_code: #{exit_code}")
        log_to_file("  stdout: #{stdout.strip}") if stdout.present?
        log_to_file("  stderr: #{stderr.strip}") if stderr.present?
      end

      private

      sig { returns(String) }
      def timestamp
        "#{color(:dim)}[#{Time.now.strftime('%H:%M:%S')}]#{color(:reset)}"
      end

      sig { params(name: Symbol).returns(String) }
      def color(name)
        return "" unless $stdout.tty?
        COLORS[name] || ""
      end

      sig { params(seconds: Float).returns(String) }
      def format_duration(seconds)
        if seconds < 1
          "#{(seconds * 1000).round}ms"
        elsif seconds < 60
          "#{seconds.round(1)}s"
        else
          "#{(seconds / 60).round}m#{(seconds % 60).round}s"
        end
      end

      sig { params(message: String).void }
      def log_to_file(message)
        log_file = Caco.config.log_file
        ::File.write(log_file, "#{message}\n", mode: "a")
      rescue => e
        # Silently ignore file write errors
      end
    end
  end
end
