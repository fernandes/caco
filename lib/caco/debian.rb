require 'caco/debian/apt_repo_add'
require 'caco/debian/apt_update'
require 'caco/debian/package_install'
require 'caco/debian/package_installed'

module Caco
  module Debian
    @@apt_updated = false

    def self.apt_updated
      @@apt_updated
    end

    def self.apt_updated=(value)
      @@apt_updated = !!value
    end
  end
end
