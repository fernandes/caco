module Caco::Debian
  class AptUpdate < Trailblazer::Operation
    step :apt_needs_update, Output(Trailblazer::Activity::Left, :failure) => End(:success)
    step Subprocess(Caco::Executer),
      input: :executer_input,
      output: :executer_output
    step :apt_updated
    fail :command_failed
      
    def apt_needs_update(ctx, params:, **)
      ctx[:apt_needs_update] = !Caco::Debian.apt_updated
      ctx[:apt_needs_update] = true if params[:force]
      ctx[:apt_needs_update]
    end
    
    def apt_updated(ctx, params:, **)
      ctx[:apt_updated] = true
      Caco::Debian.apt_updated = true
    end

    def command_failed(ctx, command_exit_code:, command_output:, **)
      ctx[:apt_updated] = false
      Caco::Debian.apt_updated = false
      true
    end

    private
      def executer_input(original_ctx, **)
        { params: { command: "apt-get update" } }
      end
    
      def executer_output(scoped_ctx, exit_code:, output:, **)
        { command_exit_code: exit_code, command_output: output }
      end
  end
end
