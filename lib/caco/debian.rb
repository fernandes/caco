require 'caco/debian/apt_repo_add'
require 'caco/debian/apt_key_install'
require 'caco/debian/apt_sources_list'
require 'caco/debian/apt_update'
require 'caco/debian/package_installed'
require 'caco/debian/package_install'

# Templates
require 'caco/debian/cell/sources_list'

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
