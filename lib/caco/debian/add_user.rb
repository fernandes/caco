module Caco::Debian
  class AddUser < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:user)
    step Caco::Macro::NormalizeParams()

    step Subprocess(Caco::Debian::UserHome),
      input:  ->(_ctx, user:, **) do { params: {
        user: user
      } } end,
      Output(:success) => End(:success),
      Output(:failure) => Track(:success)

    step Subprocess(Caco::Executer),
      input:  ->(_ctx, user:, **) do { params: {
        command: "adduser --disabled-password --gecos '' --quiet --force-badname #{user}"
      } } end
    step :mark_created

    def mark_created(ctx, **)
      ctx[:created] = true
    end
  end
end
