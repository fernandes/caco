# typed: true
class Caco::Resource::Package < Caco::Resource::Base
  module AptProvider
    extend T::Sig
    extend Caco::Resource::Package::BaseProvider

    sig {override.params(name: String, source: T.nilable(Symbol)).returns(T::Boolean)}
    def self.install_package(name, source = nil)
      Caco.execute "apt-get install -y #{name}"
      true
    end

    sig {override.params(name: String, source: T.nilable(Symbol)).returns(T::Boolean)}
    def self.uninstall_package(name, source = nil)
      Caco.execute "apt-get remove -y #{name}"
      true
    end

    sig {override.params(name: String, source: T.nilable(Symbol)).returns(T::Boolean)}
    def self.package_installed?(name, source = nil)
      return false if Caco.execute("dpkg -s #{name}")[:exit_code] != 0

      result = Caco.execute "dpkg-query -W -f='${Status} ${Version}\n' #{name}"
      return true if result[:output].match?(/^install/)

      false
    end
  end
end

