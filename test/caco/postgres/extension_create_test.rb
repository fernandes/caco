require "test_helper"

class Caco::Postgres::ExtensionCreateTest < Minitest::Test
  def test_create_new_extension
    sql_output = <<~EOF
        datname 
      ---------
      (0 rows)
    EOF
    returns = [
      [[true, 0, sql_output], ["su -l -c \"psql -e -U postgres -d postgres <<EOF\n      select extname from pg_extension where extname='foo';\n      EOF\n      \" postgres"]],
      [[true, 0, sql_output], ["su -l -c \"psql -e -U postgres -d postgres <<EOF\n      create extension foo;\n      EOF\n      \" postgres"]]
    ]

    executer_stub(returns) do
      params = {extension: "foo"}
      result = described_class.call(**params)
      assert result.success?

      assert result[:created]
      assert result[:changed]
    end
  end

  def test_create_existing_extension
    sql_output = <<~EOF
          extname    
      ---------------
       pg_prometheus
      (1 row)
    EOF
    returns = [
      [[true, 0, sql_output], ["su -l -c \"psql -e -U postgres -d postgres <<EOF\n      select extname from pg_extension where extname='pg_prometheus';\n      EOF\n      \" postgres"]]
    ]

    executer_stub(returns) do
      params = {extension: "pg_prometheus"}
      result = described_class.call(**params)
      assert result.success?
      refute result[:created]
      refute result[:changed]
    end
  end
end
