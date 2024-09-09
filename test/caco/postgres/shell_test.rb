require "test_helper"

class Caco::Postgres::ShellTest < Minitest::Test
  def setup
    @command = "createdb foo"
  end

  def test_success_shell_command
    returns = [
      [[true, 0, ""], ["su -c \"createdb foo\" postgres"]]
    ]

    executer_stub(returns) do
      params = {command: @command}
      result = described_class.call(**params)
      assert result.success?
    end
  end

  def test_failure_shell_command
    returns = [
      [[false, 1, "database already exists"], ["su -c \"createdb foo\" postgres"]]
    ]

    executer_stub(returns) do
      params = {command: @command}
      result = described_class.call(**params)
      assert result.failure?
      assert_equal 1, result[:exit_code]
      assert_equal "database already exists", result[:output]
    end
  end
end
