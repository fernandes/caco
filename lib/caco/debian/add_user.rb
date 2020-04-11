module Caco::Debian
  class AddUser < Trailblazer::Operation
    step Subprocess(Caco::Debian::UserHome),
      input: ->(_ctx, user:, **) {{
        user: user
      }},
      Output(:success) => End(:success),
      Output(:failure) => Track(:success)

    step Subprocess(Caco::Executer),
      input: ->(_ctx, user:, **) {{
        command: "adduser --disabled-password --gecos '' --quiet --force-badname #{user}"
      }}

    step ->(ctx, **) { ctx[:created] = true },
      id: :mark_created
  end
end
