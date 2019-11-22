module Caco::Debian::Cell
  class SourcesList < Trailblazer::Cell
    def mirror_url
      property(:mirror_url) || Settings.debian.apt_default_repo.mirror_url
    end
  end
end
