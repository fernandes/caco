module Caco::Debian::Cell
  class SourcesList < Trailblazer::Cell
    def mirror_url
      property(:mirror_url) || Settings.debian.apt_default_repo.mirror_url
    end

    def property(key)
      return nil if model.nil?
      return nil unless model.has_key?(key) and model.is_a?(Hash)
      return model[key]
    end
  end
end
