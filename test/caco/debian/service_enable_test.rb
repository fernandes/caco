require "test_helper"

class Caco::Debian::ServiceEnableTest < Minitest::Test
  def test_enable_service
    returns = [
      [[true, 0, ""], ['systemctl list-units --full -all | grep -Fq "haproxy.service"']],
      [[false, 1, "disabled"], ['systemctl is-enabled haproxy.service']],
      [[true, 0, stub_service_enabled_message], ['systemctl enable haproxy.service']],
    ]

    executer_stub(returns) do
      result = described_class.(params: { service: "haproxy" })
      assert result.success?
      assert result[:enabled]
    end
  end

  def test_enable_unknown_service
    returns = [
      [[false, 1, ""], ['systemctl list-units --full -all | grep -Fq "haproxy.service"']],
    ]

    executer_stub(returns) do
      result = described_class.(params: { service: "haproxy" })
      assert result.failure?
      refute result[:enabled]
    end
  end

  def test_enable_already_enabled_service
    returns = [
      [[true, 0, ""], ['systemctl list-units --full -all | grep -Fq "haproxy.service"']],
      [[true, 0, "enabled"], ['systemctl is-enabled haproxy.service']],
    ]

    executer_stub(returns) do
      result = described_class.(params: { service: "haproxy" })
      assert result.success?
      refute result[:enabled]
    end
  end

  def stub_service_enabled_message
    <<~EOF
    Synchronizing state of haproxy.service with SysV service script with /lib/systemd/systemd-sysv-install.
    Executing: /lib/systemd/systemd-sysv-install enable haproxy
    EOF
  end
end
