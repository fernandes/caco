class Caco::Debian::UserHome < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:user)
  step Caco::Macro::NormalizeParams()

  step Subprocess(Caco::FileReader),
    input:  ->(_ctx, **) do { params: {
      path: "/etc/passwd",
    } } end
  step :find_user_home

  def find_user_home(ctx, user:, **)
    match = ctx[:output].match(/^#{user}:[^:]*:[^:]*:[^:]*:[^:]*:([^:]*):.*$/)
    return false unless match
    ctx[:user_home] = match[1]
  end
end
