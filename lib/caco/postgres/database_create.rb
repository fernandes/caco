module Caco::Postgres
  class DatabaseCreate < Trailblazer::Operation

    step Subprocess(Caco::Postgres::Sql),
      input: ->(_ctx, database:, **) {{
        sql: "select datname from pg_database where datname='#{database}';",
      }},
      id: :sql_find_database

    step ->(_ctx, output:, database:, **) {
        output.match?(/^\s#{database}$/)
      },
      Output(:success) => End(:success),
      Output(:failure) => Track(:success),
      id: :verify_database_exists

    step Subprocess(Caco::Executer),
      input: ->(ctx, database:, **) {{
        command: "createdb -e #{ctx[:additional_args]} #{database}",
      }},
      id: :create_database

    step ->(ctx, **) {
        ctx[:created] = ctx[:changed] = true
      },
      id: :mark_created
  end
end
