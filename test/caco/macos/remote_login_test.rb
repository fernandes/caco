require "test_helper"

class Caco::Macos::RemoteLoginTest < Minitest::Test
  SSH_PLIST = "/System/Library/LaunchDaemons/ssh.plist"

  def test_enable_when_disabled
    returns = [
      [[false, 1, ""], ["sudo launchctl list | grep -q com.openssh.sshd"]],
      [[true, 0, ""], ["sudo launchctl load -w #{SSH_PLIST}"]]
    ]

    executer_stub(returns) do
      result = Caco::Macos::RemoteLogin.enable
      assert result
    end
  end

  def test_enable_when_already_enabled
    returns = [
      [[true, 0, ""], ["sudo launchctl list | grep -q com.openssh.sshd"]]
    ]

    executer_stub(returns) do
      result = Caco::Macos::RemoteLogin.enable
      assert result
    end
  end

  def test_disable_when_enabled
    returns = [
      [[true, 0, ""], ["sudo launchctl list | grep -q com.openssh.sshd"]],
      [[true, 0, ""], ["sudo launchctl unload -w #{SSH_PLIST}"]]
    ]

    executer_stub(returns) do
      result = Caco::Macos::RemoteLogin.disable
      assert result
    end
  end

  def test_disable_when_already_disabled
    returns = [
      [[false, 1, ""], ["sudo launchctl list | grep -q com.openssh.sshd"]]
    ]

    executer_stub(returns) do
      result = Caco::Macos::RemoteLogin.disable
      assert result
    end
  end

  def test_enabled_returns_true_when_running
    returns = [
      [[true, 0, ""], ["sudo launchctl list | grep -q com.openssh.sshd"]]
    ]

    executer_stub(returns) do
      assert Caco::Macos::RemoteLogin.enabled?
    end
  end

  def test_enabled_returns_false_when_not_running
    returns = [
      [[false, 1, ""], ["sudo launchctl list | grep -q com.openssh.sshd"]]
    ]

    executer_stub(returns) do
      refute Caco::Macos::RemoteLogin.enabled?
    end
  end
end
