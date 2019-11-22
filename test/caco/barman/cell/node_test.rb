require "test_helper"

class Caco::Barman::Cell::NodeTest < Minitest::Test
  def test_output
    output = described_class.(name: "barman", description: "Desc", host: "primary_db").to_s
    assert_equal output, default_output
  end

  def default_output
    <<~EOF
    [barman]
    description = "Desc"
    conninfo = host=primary_db user=barman dbname=postgres
    streaming_conninfo = host=primary_db user=streaming_barman
    backup_method = postgres
    streaming_archiver = on
    archiver = on
    slot_name = barman
    EOF
  end
end
