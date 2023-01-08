# typed: true
class Caco::Resource::Service < Caco::Resource::Base
  sig {returns(Symbol)}
  attr_accessor :guard

  sig { override.void }
  def make_absent
  end

  sig { override.void }
  def make_present
    disable_service if guard == :absent
    enable_service if guard == :present
  end

  private
  def enable_service
    return true if service_enabled?

    resolved_provider.enable_service(name)
  end

  def disable_service
    return true unless service_enabled?

    resolved_provider.disable_service(name)
  end

  def service_enabled?
    resolved_provider.service_enabled?(name)
  end

  def resolved_provider
    @resolved_provider ||= case Caco::Facter.("os", "name")
    when "Darwin"
      LaunchdProvider
    when "Debian"
      SystemdProvider
    end
  end
end

