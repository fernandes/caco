require 'net/http'
require "open-uri"

module Caco
  class Downloader < Trailblazer::Operation
    Stubbed = Class.new(Trailblazer::Activity::Signal)

    step Caco::Macro::ValidateParamPresence(:url)
    step Caco::Macro::ValidateParamPresence(:dest)
    step Caco::Macro::NormalizeParams()
    step :check_stubbed,
      Output(Stubbed, :stubbed) => Track(:stubbed)
    
    step :download_file
    step :stubbed_download_file, magnetic_to: :stubbed

    step :check_md5
    step :write_file

    def check_stubbed(ctx, **)
      return (ctx[:stubbed_file] ? Stubbed : true)
    end

    def download_file(ctx, url:, dest:, params:, **)
      ctx[:tempfile] = Down.download(url)
    end

    def stubbed_download_file(ctx, url:, dest:, params:, **)
      ctx[:tempfile] = File.new(ctx[:stubbed_file])
    end

    def check_md5(ctx, tempfile:, **)
      true
    end

    def write_file(ctx, tempfile:, dest:, **)
      if Caco.config.write_files
        FileUtils.mkdir_p(File.dirname(dest))
        File.rename tempfile.path, dest
      else
        tempfile.unlink
      end
    end
  end
end
