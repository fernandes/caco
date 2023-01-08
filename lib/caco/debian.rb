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
