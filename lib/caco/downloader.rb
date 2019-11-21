require 'net/http'
require "open-uri"

module Caco
  class Downloader < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:url)
    step Caco::Macro::ValidateParamPresence(:dest)
    step Caco::Macro::NormalizeParams()
    step :download_file
    step :check_md5
    step :write_file

    def download_file(ctx, url:, dest:, params:, **)
      ctx[:tempfile] = tempfile = Down.download(url)
      # Down::ConnectionError
      # Down::NotFound
    end

    def check_md5(ctx, tempfile:, **)
      true
    end

    def write_file(ctx, tempfile:, dest:, **)
      if Caco.config.write_files
        FileUtils.move(tempfile, dest)
      else
        tempfile.unlink
      end
    end
  end
end
