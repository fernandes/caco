require "test_helper"

class Caco::Resource::ExecuteTest < Minitest::Test
  def test_real_success
    result = Caco.execute "echo 'hello world'"
    assert_equal 0, result.exit_code
    assert_equal "hello world\n", result.output
  end

  def test_real_output
    result = caco do
      execute "echo '-n boom'",
        command: ["echo", "-n", "boom"]
    end
    assert_equal "boom", result.output
  end

  def test_real_exit_code
    result = Caco.execute "echo; exit 7"
    assert_equal 7, result.exit_code
  end
 
  # This test is like a remined if I need to run a sequence of commandss
  def test_multiple_stubs
    returns = [
      [[true, 0, "out 1"], ['command_1']],
      [[false, 1, "out 2", "stderror"], ['command_2']],
      [[true, 0, "out 3"], ['command_3']]
    ]

    executer_stub(returns) do
      assert_equal [true, 0, "out 1", nil], Caco.execute("command_1").signal
      assert_equal [false, 1, "out 2", "stderror"], Caco.execute("command_2").signal
      assert_equal [true, 0, "out 3", nil], Caco.execute("command_3").signal
    end
  end

  def stub_output
    <<~EOF
    total 40K
    drwxr-xr-x 1 caco caco  608 Nov 18 15:07 .
    drwxr-xr-x 1 caco caco  544 Nov 18 14:55 ..
    drwxr-xr-x 1 caco caco  128 Nov 18 14:55 bin
    drwxr-xr-x 1 caco caco   96 Nov 18 14:55 .bundle
    -rw-r--r-- 1 caco caco 2.0K Nov 18 15:26 caco.gemspec
    EOF
  end
end

