require 'net/http'
require "open-uri"

module Caco
  class Downloader < Trailblazer::Operation
    Stubbed = Class.new(Trailblazer::Activity::Signal)

    step ->(_ctx, stubbed_file: nil, **) {
        stubbed_file ? Stubbed : true
      },
      Output(Stubbed, :stubbed) => Track(:stubbed),
      id: :check_stubbed

    step ->(ctx, url:, **) {
        ctx[:tempfile] = Down.download(url)
      },
      id: :download_file
    
    step ->(ctx, stubbed_file:, **) {
        ctx[:tempfile] = File.new(ctx[:stubbed_file])
      },
      magnetic_to: :stubbed,
      id: :stubbed_download_file

    step ->(_ctx, **) {
        true
      },
      id: :check_md5

    step :write_file

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
