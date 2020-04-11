module Caco::Debian
  class AptUpdate < Trailblazer::Operation
    step :apt_needs_update,
      Output(Trailblazer::Activity::Left, :failure) => End(:success)

    step Subprocess(Caco::Executer),
      input: ->(_ctx, **) {{
        command: 'apt-get update'
      }},
      output: { exit_code: :command_exit_code, output: :command_output }

    step :apt_updated

    fail :command_failed

    def apt_needs_update(ctx, force: false, **)
      ctx[:apt_needs_update] = !Caco::Debian.apt_updated
      ctx[:apt_needs_update] = true if force
      ctx[:apt_needs_update]
    end

    def apt_updated(ctx, **)
      ctx[:apt_updated] = true
      Caco::Debian.apt_updated = true
    end

    def command_failed(ctx, command_exit_code:, command_output:, **)
      ctx[:apt_updated] = false
      Caco::Debian.apt_updated = false
      true
    end
  end
end
