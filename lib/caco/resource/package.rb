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

    os.install_package(name)
  end

  def uninstall_package
    return true unless package_installed?

    os.uninstall_package(name)
  end


  def package_installed?
    os.package_installed?(name)
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

