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

    os.enable_service(name)
  end

  def disable_service
    return true unless service_enabled?

    os.disable_service(name)
  end

  def service_enabled?
    os.service_enabled?(name)
  end

  def os
    @os ||= case Caco::Facter.("os", "name")
    when "Darwin"
      Caco::OS::Macos
    when "Debian"
      Caco::OS::Debian
    end
  end
end

