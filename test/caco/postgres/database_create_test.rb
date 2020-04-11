require "test_helper"

class Caco::Postgres::DatabaseCreateTest < Minitest::Test
  def test_create_new_database
    sql_output = <<~EOF
      datname 
    ---------
    (0 rows)
    EOF
    returns = [
      [[true, 0, sql_output], ["su -l -c \"psql -e -U postgres -d postgres <<EOF\n      select datname from pg_database where datname='foo';\n      EOF\n      \" postgres"]],
      [[true, 0, ""], ["createdb -e  foo"]],
    ]

    executer_stub(returns) do
      params = { database: "foo" }
      result = described_class.(params)
      assert result.success?

      assert result[:created]
      assert result[:changed]
    end
  end

  def test_create_existing_database
    sql_output = <<~EOF
      datname   
    ------------
     foo
    (1 row)
    EOF
    returns = [
      [[true, 0, sql_output], ["su -l -c \"psql -e -U postgres -d postgres <<EOF\n      select datname from pg_database where datname='foo';\n      EOF\n      \" postgres"]],
    ]

    executer_stub(returns) do
      params = { database: "foo" }
      result = described_class.(params)
      assert result.success?
      refute result[:created]
      refute result[:changed]
    end
  end
end
