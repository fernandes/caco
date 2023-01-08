# typed: true
class Caco::Resource::Package < Caco::Resource::Base
  sig {returns(Symbol)}
  attr_accessor :guard

  sig {returns(T.nilable(Symbol))}
  attr_accessor :source

  sig {returns(T.nilable(Symbol))}
  attr_accessor :provider

  sig { override.void }
  def make_absent
  end

  sig { override.void }
  def make_present
    uninstall_package if guard == :absent
    install_package if guard == :present
  end

  private
  def install_package
    return true if package_installed?

    internal_provider.install_package(name)
  end

  def uninstall_package
    return true unless package_installed?

    internal_provider.uninstall_package(name)
  end


  def package_installed?
    internal_provider.package_installed?(name)
  end

  def internal_provider
    @internal_provider ||= case Caco::Facter.("os", "name")
    when "Darwin"
      BrewProvider
    when "Debian"
      AptProvider
    end
  end
end

