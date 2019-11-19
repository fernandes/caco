module Caco::Debian
  class AptUpdate < Trailblazer::Operation
    step :apt_needs_update, Output(Trailblazer::Activity::Left, :failure) => End(:success)
    step :apt_update

    def apt_needs_update(ctx, params:, **)
      ctx[:apt_needs_update] = !Caco::Debian.apt_updated
      ctx[:apt_needs_update] = true if params[:force]
      ctx[:apt_needs_update]
    end

    def apt_update(ctx, params:, **)
      s, e, o = Caco::Executer.(command: "apt-get update")
      Caco::Debian.apt_updated = s
      ctx[:apt_updated] = s
    end
  end
end
