require "test_helper"
require_relative "./conf_helper"

class Caco::Postgres::ConfSetTest < Minitest::Test
  include Caco::Postgres::ConfHelper

  def test_set_single_value
    result = described_class.(name: "aug", value: "foo", augeas_path: TMP_PATH)
    assert result.success?
    assert_equal ["foo"], result[:value]
    refute result[:created]
    assert result[:changed]

    conf_output = File.read("#{TMP_PATH}/postgresql.conf")
    assert conf_output.match(/^aug = foo$/)
  end

  def test_set_single_value_same_value
    result = described_class.(name: "aug", value: "on", augeas_path: TMP_PATH)
    assert result.success?
    assert_equal "on", result[:value]
    refute result[:created]
    refute result[:changed]

    conf_output = File.read("#{TMP_PATH}/postgresql.conf")
    assert conf_output.match(/^aug = on$/)
  end

  def test_set_new_config_value
    result = described_class.(name: "newone", value: "foo", augeas_path: TMP_PATH)
    assert result.success?
    assert_equal ["foo"], result[:value]
    assert result[:created]
    assert result[:changed]

    conf_output = File.read("#{TMP_PATH}/postgresql.conf")
    assert conf_output.match(/^newone = 'foo'$/)
  end

  def test_set_multiple_values
    result = described_class.(values: {aug: "foo", bar: "baz", param1: "lol"}, augeas_path: TMP_PATH)
    assert result.success?
    assert result[:created]
    assert result[:changed]
    assert_equal ["foo"], result[:values]["aug"]
    assert_equal ["baz"], result[:values]["bar"]
    assert_equal ["lol"], result[:values]["param1"]

    # wont set to created or changed on second run
    result = described_class.(values: {aug: "foo", bar: "baz", param1: "lol"}, augeas_path: TMP_PATH)
    assert result.success?
    refute result[:created]
    refute result[:changed]
  end
end
