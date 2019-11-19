require "test_helper"
require_relative "./conf_helper"

class Caco::Postgres::ConfSetTest < Minitest::Test
  include Caco::Postgres::ConfHelper

  def test_set_single_value
    result = described_class.(params: {name: "aug", value: "foo", augeas_path: @tmp_path})
    assert result.success?
    assert_equal ["foo"], result[:value]

    conf_output = File.read("#{@tmp_path}/postgresql.conf")
    assert conf_output.match(/^aug = foo$/)
  end

  def test_set_multiple_values
    result = described_class.(params: {values: {aug: "foo", bar: "baz", param1: "lol"}, augeas_path: @tmp_path})
    assert result.success?
    assert_equal ["foo"], result[:values]["aug"]
    assert_equal ["baz"], result[:values]["bar"]
    assert_equal ["lol"], result[:values]["param1"]
  end
end
