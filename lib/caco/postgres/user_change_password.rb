module Caco::Postgres
  class UserChangePassword < Trailblazer::Operation
    step ->(ctx, user:, password:, **) {
        ctx[:sql] = "alter user #{user} with password '#{password}';"
      },
      id: :build_sql

    step Subprocess(Caco::Postgres::Sql),
      input: ->(_ctx, sql:, **) {{
        sql: sql,
      }}
  end
end
