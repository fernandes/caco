require "test_helper"

class Caco::Resource::ResultTest < Minitest::Test
  def test_attributes
    result = described_class.new(created: true, changed: false, exit_code: 0)
    assert result.created?
    refute result.changed?
    assert_equal 0, result.exit_code
  end

  def test_can_change_attributes
    result = described_class.new(created: true)
    assert result.created?
    result.created = false
    refute result.created?
  end
end

