module Caco::Postgres
  class ExtensionCreate < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:extension)
    step Caco::Macro::NormalizeParams()
    step Subprocess(Caco::Postgres::Sql),
      input:  ->(_ctx, extension:, **) do { params: {
        sql: "select extname from pg_extension where extname='#{extension}';",
      } } end,
      id: :sql_find_extension
    step :verify_extension_exists,
      Output(:success) => End(:success),
      Output(:failure) => Track(:success)
    step Subprocess(Class.new(Caco::Postgres::Sql)),
      input:  ->(_ctx, extension:, **) do { params: {
        sql: "create extension #{extension};",
      } } end,
      id: :create_extension
    step :mark_created
    
    def verify_extension_exists(ctx, output:, extension:, **)
      output.match?(/^\s#{extension}$/)
    end

    def mark_created(ctx, **)
      ctx[:created] = true
      ctx[:changed] = true
    end
  end
end
