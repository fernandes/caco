# typed: true
module Caco::OS::Base
  extend T::Sig
  extend T::Helpers
  interface!

  # Package
  sig {abstract.params(name: String).returns(T::Boolean)}
  def install_package(name); end

  sig {abstract.params(name: String).returns(T::Boolean)}
  def uninstall_package(name); end

  sig {abstract.params(name: String).returns(T::Boolean)}
  def package_installed?(name); end

  # Service?
  sig {abstract.params(name: String).returns(T::Boolean)}
  def enable_service(name); end

  sig {abstract.params(name: String).returns(T::Boolean)}
  def disable_service(name); end

  sig {abstract.params(name: String).returns(T::Boolean)}
  def service_enabled?(name); end
end
