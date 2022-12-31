require "test_helper"

class Caco::Haproxy::ConfSetTest < Minitest::Test
  def setup
    clean_tmp_path
    Caco.file "/etc/default/haproxy", content: default_config_file
  end

  def test_set_existing_option
    result = described_class.(name: "CONFIG", value: "/etc/haproxy/haproxy.config")
    assert result.success?
    refute result[:created]
    assert result[:changed]
    assert_equal "/etc/haproxy/haproxy.config", result[:value]

    # Test File Config
    result = Caco::FileReader.(path: "/etc/default/haproxy")
    assert_equal config_after_test_set_existing_option, result[:output]
  end

  def test_set_same_option_does_not_change
    result = described_class.(name: "CONFIG", value: "/etc/haproxy/haproxy.cfg")
    assert result.success?
    refute result[:created]
    refute result[:changed]
    assert_equal "/etc/haproxy/haproxy.cfg", result[:value]

    # Test File Config
    result = Caco::FileReader.(path: "/etc/default/haproxy")
    assert_equal default_config_file, result[:output]
  end

  def test_set_non_existing_option
    result = described_class.(name: "EXTRAOPTS", value: "-de -m 32")
    assert result.success?
    assert_equal "-de -m 32", result[:value]
    assert result[:created]
    assert result[:changed]

    # Test File Config
    result = Caco::FileReader.(path: "/etc/default/haproxy" )
    assert_equal config_after_test_set_non_existing_option, result[:output]
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

    # This is a dummy option
    #DUMMY_OPTION="dummy"
    EOF
  end

  def config_after_test_set_existing_option
    <<~EOF    
    # Defaults file for HAProxy
    #
    # This is sourced by both, the initscript and the systemd unit file, so do not
    # treat it as a shell script fragment.

    # Change the config file location if needed
    CONFIG="/etc/haproxy/haproxy.config"

    # Add extra flags here, see haproxy(1) for a few options
    #EXTRAOPTS="-de -m 16"

    # This is a dummy option
    #DUMMY_OPTION="dummy"
    EOF
  end

  def config_after_test_set_non_existing_option
    <<~EOF    
    # Defaults file for HAProxy
    #
    # This is sourced by both, the initscript and the systemd unit file, so do not
    # treat it as a shell script fragment.

    # Change the config file location if needed
    CONFIG="/etc/haproxy/haproxy.cfg"

    # Add extra flags here, see haproxy(1) for a few options
    #EXTRAOPTS="-de -m 16"

    # This is a dummy option
    #DUMMY_OPTION="dummy"
    EXTRAOPTS="-de -m 32"
    EOF
  end
end
