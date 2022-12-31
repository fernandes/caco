# typed: true
module Caco::OS::Macos
  extend T::Sig
  extend Caco::OS::Base

  sig {override.params(name: String).returns(T::Boolean)}
  def self.install_package(name)
    Caco.execute("brew install #{name}")
    true
  end

  sig {override.params(name: String).returns(T::Boolean)}
  def self.uninstall_package(name)
    Caco.execute("brew uninstall #{name}")
    true
  end

  sig {override.params(name: String).returns(T::Boolean)}
  def self.package_installed?(name)
    Caco.execute("brew info #{name}")[:exit_code] == 0
  end
end
