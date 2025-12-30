# typed: true
module Caco::Macos::RemoteLogin
  extend T::Sig

  SSH_PLIST = "/System/Library/LaunchDaemons/ssh.plist"

  sig { returns(T::Boolean) }
  def self.enabled?
    # Check if sshd is running
    result = Caco.execute("sudo launchctl list | grep -q com.openssh.sshd")
    result[:exit_code] == 0
  end

  sig { returns(T::Boolean) }
  def self.enable
    return true if enabled?

    result = Caco.execute("sudo launchctl load -w #{SSH_PLIST}")
    result[:exit_code] == 0
  end

  sig { returns(T::Boolean) }
  def self.disable
    return true unless enabled?

    result = Caco.execute("sudo launchctl unload -w #{SSH_PLIST}")
    result[:exit_code] == 0
  end
end
