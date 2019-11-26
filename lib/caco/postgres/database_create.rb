module Caco::Postgres
  class DatabaseCreate < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:database)
    step Caco::Macro::NormalizeParams()
    step Subprocess(Caco::Postgres::Sql),
      input:  ->(_ctx, database:, **) do { params: {
        sql: "select datname from pg_database where datname='#{database}';",
      } } end,
      id: :sql_find_database
    step :verify_database_exists,
      Output(:success) => End(:success),
      Output(:failure) => Track(:success)
    step Subprocess(Caco::Executer),
      input:  ->(ctx, database:, **) do { params: {
        command: "createdb -e #{ctx[:additional_args]} #{database}",
      } } end,
      id: :create_database
    step :mark_created
    
    def verify_database_exists(ctx, output:, database:, **)
      output.match?(/^\s#{database}$/)
    end

    def mark_created(ctx, **)
      ctx[:created] = true
      ctx[:changed] = true
    end
  end
end
