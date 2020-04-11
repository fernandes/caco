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

    step Subprocess(Caco::FileWriter),
      input: [:path, :content],
      output: { file_created: :repo_created, file_changed: :repo_changed }
  end
end
