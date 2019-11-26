module Caco::Postgres
  class UserChangePassword < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:user)
    step Caco::Macro::ValidateParamPresence(:password)
    step Caco::Macro::NormalizeParams()
    step :build_sql
    step Subprocess(Caco::Postgres::Sql),
      input:  ->(_ctx, sql:, **) do { params: {
        sql: sql,
      } } end
    
    def build_sql(ctx, user:, password:, **)
      ctx[:sql] = "alter user #{user} with password '#{password}';"
    end
  end
end
