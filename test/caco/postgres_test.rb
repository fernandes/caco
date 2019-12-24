require "test_helper"

class Caco::PostgresTest < Minitest::Test
  def setup
    described_class.clear_shared_library
  end

  def test_add_shared_library
    described_class.add_shared_library("timescaledb")
    described_class.add_shared_library("pg_prometheus")
    assert_equal "timescaledb, pg_prometheus", described_class.shared_libraries

    described_class.clear_shared_library
    assert_equal "", described_class.shared_libraries
  end

  def should_restart
    refute described_class.should_restart?
    described_class.should_restart!
    assert described_class.should_restart?
  end
end
