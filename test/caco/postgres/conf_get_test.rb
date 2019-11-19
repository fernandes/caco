require "test_helper"
require_relative "./conf_helper"

class Caco::Postgres::ConfGetTest < Minitest::Test
  include Caco::Postgres::ConfHelper

  def test_get_single_value
    result = described_class.(params: {name: "aug", augeas_path: TMP_PATH})
    assert result.success?
    assert_equal "on", result[:value]
  end

  def test_get_multiple_values
    result = described_class.(params: {names: ["aug", "param5", "unknown"], augeas_path: TMP_PATH})
    assert result.success?
    assert_equal "on", result[:values]["aug"]
    assert_equal "on", result[:values]["param5"]
    assert_nil result[:values]["unknown"]
  end
end
