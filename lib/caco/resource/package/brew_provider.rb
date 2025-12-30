# typed: true
class Caco::Resource::Package < Caco::Resource::Base
  module BrewProvider
    extend T::Sig
    extend Caco::Resource::Package::BaseProvider

    sig {override.params(name: String, source: T.nilable(Symbol)).returns(T::Boolean)}
    def self.install_package(name, source = nil)
      brew_cmd = case source
      when :cask
        "brew install --cask #{name}"
      else
        "brew install #{name}"
      end
      result = Caco.execute(as_brew_user(brew_cmd))
      result[:exit_code] == 0
    end

    sig {override.params(name: String, source: T.nilable(Symbol)).returns(T::Boolean)}
    def self.uninstall_package(name, source = nil)
      brew_cmd = case source
      when :cask
        "brew uninstall --cask #{name}"
      else
        "brew uninstall #{name}"
      end
      result = Caco.execute(as_brew_user(brew_cmd))
      result[:exit_code] == 0
    end

    sig {override.params(name: String, source: T.nilable(Symbol)).returns(T::Boolean)}
    def self.package_installed?(name, source = nil)
      brew_cmd = case source
      when :cask
        "brew list --cask | egrep -q \"^#{name}$\""
      else
        "brew list | egrep -q \"^#{name}$\""
      end
      Caco.execute(as_brew_user(brew_cmd))[:exit_code] == 0
    end

    sig {params(cmd: String).returns(String)}
    def self.as_brew_user(cmd)
      # Homebrew should run as the user, not root
      # Use SUDO_USER if running via sudo, otherwise run directly
      brew_user = ENV["SUDO_USER"]
      if brew_user && Process.uid == 0
        "sudo -u #{brew_user} #{cmd}"
      else
        cmd
      end
    end
  end
end

