# typed: true
module Caco::Resource::Service::BaseProvider
  extend T::Sig
  extend T::Helpers
  interface!

  # Service?
  sig {abstract.params(name: String).returns(T::Boolean)}
  def enable_service(name); end

  sig {abstract.params(name: String).returns(T::Boolean)}
  def disable_service(name); end

  sig {abstract.params(name: String).returns(T::Boolean)}
  def service_enabled?(name); end
end

