module Caco::Postgres
  class UserCreate < Trailblazer::Operation
    step Subprocess(Caco::Postgres::Sql),
      input: ->(_ctx, user:, **) {{
        sql: "select usename from pg_user where usename='#{user}';",
      }},
      id: :sql_find_user

    step ->(_ctx, output:, user:, **) {
        output.match?(/^\s#{user}$/)
      },
      Output(:success) => End(:success),
      Output(:failure) => Track(:success),
      id: :verify_user_exists

    step Subprocess(Caco::Executer),
      input: ->(ctx, user:, **) {{
        command: "createuser -e #{user} #{ctx[:additional_args]}",
      }},
      id: :create_user

    step Subprocess(Caco::Postgres::UserChangePassword),
      input: ->(ctx, user:, password:, **) {{
        user: user, password: password,
      }},
      id: :user_change_password
    
    step ->(ctx, **) {
        ctx[:created] = ctx[:changed] = true
      },
      id: :mark_created
  end
end
