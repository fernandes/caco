# typed: true
class Caco::Resource::Package < Caco::Resource::Base
  module BrewProvider
    extend T::Sig
    extend Caco::Resource::Package::BaseProvider

    sig {override.params(name: String, source: T.nilable(Symbol)).returns(T::Boolean)}
    def self.install_package(name, source = nil)
      cmd = case source
      when :cask
        "brew install --cask #{name}"
      else
        "brew install #{name}"
      end
      result = Caco.execute(cmd)
      result[:exit_code] == 0
    end

    sig {override.params(name: String, source: T.nilable(Symbol)).returns(T::Boolean)}
    def self.uninstall_package(name, source = nil)
      cmd = case source
      when :cask
        "brew uninstall --cask #{name}"
      else
        "brew uninstall #{name}"
      end
      result = Caco.execute(cmd)
      result[:exit_code] == 0
    end

    sig {override.params(name: String, source: T.nilable(Symbol)).returns(T::Boolean)}
    def self.package_installed?(name, source = nil)
      cmd = case source
      when :cask
        "brew list --cask #{name}"
      else
        "brew list #{name}"
      end
      Caco.execute(cmd)[:exit_code] == 0
    end
  end
end

