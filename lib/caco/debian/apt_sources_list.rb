module Caco::Debian
  class AptSourcesList < Trailblazer::Operation
    step ->(ctx, mirror_url: nil, **) {
        ctx[:content] = Caco::Debian::Cell::SourcesList.(mirror_url: mirror_url).to_s
      },
      id: :generate_content

    step ->(ctx, **) { ctx[:path] = '/etc/apt/sources.list' },
      id: :build_path

    step :write_file

    def write_file(ctx, path:, content:, **)
      result = file path, content: content

      ctx[:sources_updated] = result[:changed]
      true
    end
  end
end
