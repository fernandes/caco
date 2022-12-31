# typed: true
module Caco::OS::Base
  extend T::Sig
  extend T::Helpers
  interface!

  sig {abstract.params(name: String).returns(T::Boolean)}
  def install_package(name); end
 
  sig {abstract.params(name: String).returns(T::Boolean)}
  def uninstall_package(name); end

  sig {abstract.params(name: String).returns(T::Boolean)}
  def package_installed?(name); end
end
