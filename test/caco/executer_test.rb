require "test_helper"

class Caco::ExecuterTest < Minitest::Test
  def test_real_success_output
    success, exit_code, output = described_class.(command: "echo 'hello world'")
    assert success
    assert_equal 0, exit_code
    assert_equal output, "hello world\n"
  end

  def test_real_success_output
    success, exit_code, output = described_class.(command: ["echo", "-n", "boom"])
    assert success
    assert_equal "boom", output
  end

  def test_real_success_output
    success, exit_code, output = described_class.(command: "echo; exit 7")
    refute success
    assert_equal 7, exit_code
  end

  # This test is like a remined if I need to run a sequence of commandss
  def test_multiple_stubs
    @commander = Minitest::Mock.new
    @commander.expect :call, [true, 0, "out 1"], ['command_1']
    @commander.expect :call, [false, 1, "out 2"], ['command_2']
    @commander.expect :call, [true, 0, "out 3"], ['command_3']

    described_class.stub :execute, ->(command){ @commander.call(command) } do
      assert_equal [true, 0, "out 1"], described_class.(command: "command_1")
      assert_equal [false, 1, "out 2"], described_class.(command: "command_2")
      assert_equal [true, 0, "out 3"], described_class.(command: "command_3")
    end

    @commander.verify
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
