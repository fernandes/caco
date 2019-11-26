require "test_helper"

class Caco::Postgres::UserChangePasswordTest < Minitest::Test
  def test_success_sql_command
    returns = [
      [[true, 0, ""], ["su -l -c \"psql -e -U postgres -d postgres <<EOF\n      alter user foo with password 'secret';\n      EOF\n      \" postgres"]],
    ]

    executer_stub(returns) do
      params = { params: { user: "foo", password: "secret" } }
      result = described_class.(params)
      assert result.success?
    end
  end
end
