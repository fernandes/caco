require "test_helper"

class Caco::Debian::Cell::ServiceTest < Minitest::Test
  def test_output
    output = described_class.().to_s
    assert_equal output, default_output
  end

  def default_output
    <<~EOF
    # File Managed, Dot Not Edit
    [Unit]
    Description=No Description ProvidedAfter=syslog.target network.target network-online.target

    [Service]

    User=root
    Restart=on-failure
    ExecStart=[Install]
    WantedBy=multi-user.target
    EOF
  end
end
