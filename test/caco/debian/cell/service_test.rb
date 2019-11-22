require "test_helper"

class Caco::Debian::Cell::ServiceTest < Minitest::Test
  def test_output
    output = described_class.(command: "/bin/foo").to_s
    assert_equal output, default_output
  end

  def default_output
    <<~EOF
    # File Managed, Dot Not Edit
    [Unit]
    Description=No Description Provided
    After=syslog.target network.target network-online.target

    [Service]
    User=root
    Restart=on-failure
    ExecStart=/bin/foo

    [Install]
    WantedBy=multi-user.target
    EOF
  end
end
