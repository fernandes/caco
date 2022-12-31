# typed: true
require "caco/resource/execute"
module Caco::OS::Debian
  extend T::Sig
  extend Caco::OS::Base

  sig {override.params(name: String).returns(T::Boolean)}
  def self.install_package(name)
    Caco.execute "apt-get install -y #{name}"
    true
  end
 
  sig {override.params(name: String).returns(T::Boolean)}
  def self.uninstall_package(name)
    Caco.execute "apt-get remove -y #{name}"
    true
  end

  sig {override.params(name: String).returns(T::Boolean)}
  def self.package_installed?(name)
    return false if Caco.execute("dpkg -s #{name}")[:exit_code] != 0

    result = Caco.execute "dpkg-query -W -f='${Status} ${Version}\n' #{name}"
    return true if result[:output].match?(/^install/)

    false
  end

end
