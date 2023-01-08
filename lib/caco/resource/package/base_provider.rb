# typed: true
class Caco::Resource::Package < Caco::Resource::Base
  module BaseProvider
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
  end
end
 
