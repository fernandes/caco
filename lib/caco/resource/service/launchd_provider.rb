# typed: true
module Caco::Resource::Service::LaunchdProvider
  extend T::Sig
  extend Caco::Resource::Service::BaseProvider

  sig {override.params(name: String).returns(T::Boolean)}
  def self.enable_service(name)
    Caco.execute "sudo launchctl load #{name}"
    true
  end

  sig {override.params(name: String).returns(T::Boolean)}
  def self.disable_service(name)
    Caco.execute "launchctl unload #{name}"
    true
  end

  sig {override.params(name: String).returns(T::Boolean)}
  def self.service_enabled?(name)
    res = Caco.execute("sudo launchctl list|egrep -iq #{name}")
    return true if res.exit_code == 0

    false
  end
end

