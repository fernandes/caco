require "test_helper"

class Caco::Haproxy::ConfGetTest < Minitest::Test
  def setup
    clean_tmp_path
    Caco.file "/etc/default/haproxy", content: default_config_file
  end

  def test_find_option
    result = described_class.(name: "CONFIG")
    assert result.success?
    assert_equal "/etc/haproxy/haproxy.cfg", result[:value]
  end

  def test_find_non_existing_option
    result = described_class.(name: "EXTRAOPTS")
    assert result.failure?
  end

  def default_config_file
    <<~EOF    
    # Defaults file for HAProxy
    #
    # This is sourced by both, the initscript and the systemd unit file, so do not
    # treat it as a shell script fragment.

    # Change the config file location if needed
    CONFIG="/etc/haproxy/haproxy.cfg"

    # Add extra flags here, see haproxy(1) for a few options
    #EXTRAOPTS="-de -m 16"
    EOF
  end
end
