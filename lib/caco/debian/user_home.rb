module Caco::Debian
  class UserHome < Trailblazer::Operation
    step Subprocess(Caco::FileReader),
      input: ->(_ctx, **) {{
        path: "/etc/passwd",
      }},
      output: { output: :passwd_output }
    step :find_user_home

    def find_user_home(ctx, user:, passwd_output:, **)
      match = passwd_output.match(/^#{user}:[^:]*:[^:]*:[^:]*:[^:]*:([^:]*):.*$/)
      return false unless match

      ctx[:user_home] = match[1]
    end
  end
end
