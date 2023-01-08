# typed: true
module Caco::Resource::Service::SystemdProvider
  extend T::Sig
  extend Caco::Resource::Service::BaseProvider

  sig {override.params(name: String).returns(T::Boolean)}
  def self.enable_service(name)
    Caco.execute "systemctl enable #{name}"
    true
  end

  sig {override.params(name: String).returns(T::Boolean)}
  def self.disable_service(name)
    Caco.execute "systemctl disable #{name}"
    true
  end

  sig {override.params(name: String).returns(T::Boolean)}
  def self.service_enabled?(name)
    res = Caco.execute("systemctl is-enabled #{name}")
    res.exit_code == 0 && res.output.try(:match?, /^enabled/)
  end
end

