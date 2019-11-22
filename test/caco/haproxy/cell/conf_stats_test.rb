require "test_helper"

class Caco::Haproxy::Cell::ConfStatsTest < Minitest::Test
  def test_output
    output = described_class.().to_s
    assert_equal output, default_output
  end

  def default_output
    <<~EOF    
    frontend stats
      bind *:8404
      stats enable
      stats uri /stats
      stats refresh 10s
      stats admin if LOCALHOST
    EOF
  end
end
