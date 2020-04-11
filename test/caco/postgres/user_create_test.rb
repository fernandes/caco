require "test_helper"

class Caco::Postgres::UserCreateTest < Minitest::Test
  def test_add_new_user
    sql_output = <<~EOF
      usename   
    ------------
    (0 rows)
    EOF
    returns = [
      [[true, 0, sql_output], ["su -l -c \"psql -e -U postgres -d postgres <<EOF\n      select usename from pg_user where usename='foo';\n      EOF\n      \" postgres"]],
      [[true, 0, ""], ["createuser -e foo "]],
      [[true, 0, ""], ["su -l -c \"psql -e -U postgres -d postgres <<EOF\n      alter user foo with password 'secret';\n      EOF\n      \" postgres"]]
    ]

    executer_stub(returns) do
      params = { user: "foo", password: "secret" }
      result = described_class.(params)
      assert result.success?

      assert result[:created]
      assert result[:changed]
    end
  end

  def test_add_existing_user
    sql_output = <<~EOF
      usename   
    ------------
     foo
    (1 row)
    EOF
    returns = [
      [[true, 0, sql_output], ["su -l -c \"psql -e -U postgres -d postgres <<EOF\n      select usename from pg_user where usename='foo';\n      EOF\n      \" postgres"]],
    ]

    executer_stub(returns) do
      params = { user: "foo", password: "secret" }
      result = described_class.(params)
      assert result.success?
      refute result[:created]
      refute result[:changed]
    end
  end
end
