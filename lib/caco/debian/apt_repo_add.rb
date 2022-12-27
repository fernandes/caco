module Caco::Debian
  class AptRepoAdd < Trailblazer::Operation
    step ->(ctx, url:, release:, component:, **) {
        ctx[:content] = "deb #{url} #{release} #{component}"
      },
      id: :build_repo_content

    step ->(ctx, name:, **) {
        ctx[:path] = "/etc/apt/sources.list.d/#{name}.list"
      },
      id: :build_repo_path

    step :write_file

    def write_file(ctx, path:, content:, **)
      result = file path, content: content

      ctx[:repo_created] = result[:created]
      ctx[:repo_changed] = result[:changed]
    end
  end
end
