module Caco::Postgres
  class ExtensionCreate < Trailblazer::Operation

    step Subprocess(Caco::Postgres::Sql),
      input: ->(_ctx, extension:, **) {{
        sql: "select extname from pg_extension where extname='#{extension}';",
      }},
      id: :sql_find_extension

    step ->(_ctx, output:, extension:, **) {
        output.match?(/^\s#{extension}$/)
      },
      Output(:success) => End(:success),
      Output(:failure) => Track(:success),
      id: :verify_extension_exists

    step Subprocess(Class.new(Caco::Postgres::Sql)),
      input: ->(_ctx, extension:, **) {{
        sql: "create extension #{extension};",
      }},
      id: :create_extension

    step ->(ctx, **) {
        ctx[:created] = ctx[:changed] = true
      },
      id: :mark_created
  end
end
