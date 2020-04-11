require "test_helper"

class Caco::Postgres::SqlTest < Minitest::Test
  def setup
    @sql = "select now();"
  end

  def test_success_sql_command
    returns = [
      [[true, 0, ""], ["su -l -c \"psql -e -U postgres -d postgres <<EOF\n      select now();\n      EOF\n      \" postgres"]],
    ]

    executer_stub(returns) do
      params = { sql: @sql }
      result = described_class.(params)
      assert result.success?
    end
  end

  def test_failure_sql_command
    returns = [
      [[false, 1, "invalid query"], ["su -l -c \"psql -e -U postgres -d postgres <<EOF\n      select now();\n      EOF\n      \" postgres"]],
    ]

    executer_stub(returns) do
      params = { sql: @sql }
      result = described_class.(params)
      assert result.failure?
      assert_equal 1, result[:exit_code]
      assert_equal "invalid query", result[:output]
    end
  end
end
