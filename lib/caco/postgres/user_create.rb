module Caco::Postgres
  class UserCreate < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:user)
    step Caco::Macro::ValidateParamPresence(:password)
    step Caco::Macro::NormalizeParams()
    step Subprocess(Caco::Postgres::Sql),
      input:  ->(_ctx, user:, **) do { params: {
        sql: "select usename from pg_user where usename='#{user}';",
      } } end,
      id: :sql_find_user
    step :verify_user_exists,
      Output(:success) => End(:success),
      Output(:failure) => Track(:success)
    step Subprocess(Caco::Executer),
      input:  ->(ctx, user:, **) do { params: {
        command: "createuser -e #{user} #{ctx[:additional_args]}",
      } } end,
      id: :create_user
    step Subprocess(Caco::Postgres::UserChangePassword),
      input:  ->(ctx, user:, password:, **) do { params: {
        user: user, password: password,
      } } end,
      id: :user_change_password
    step :mark_created
    
    def verify_user_exists(ctx, output:, user:, **)
      output.match?(/^\s#{user}$/)
    end

    def mark_created(ctx, **)
      ctx[:created] = true
      ctx[:changed] = true
    end
  end
end
