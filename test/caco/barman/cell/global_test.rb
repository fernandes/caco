require "test_helper"

class Caco::Barman::Cell::GlobalTest < Minitest::Test
  def test_output
    FakeFS do
      fakefs_clone
      output = described_class.().to_s
      assert_equal output, default_output
    end
  end

  def default_output
    <<~EOF
    [barman]
    barman_user = barman
    configuration_files_directory = /etc/barman.d
    barman_home = /var/lib/barman
    log_file = /var/log/barman/barman.log
    log_level = INFO
    compression = gzip
    EOF
  end
end
