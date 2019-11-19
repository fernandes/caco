require "test_helper"

class Caco::Rbenv::Cell::ProfileTest < Minitest::Test
  def test_output
    output = described_class.().to_s
    assert_equal output, stub_output
  end

  def stub_output
    <<~EOF
    export PATH="/opt/rbenv/bin:$PATH"
    export RBENV_ROOT="/opt/rbenv"
    eval "$(rbenv init -)"
    EOF
  end
end
