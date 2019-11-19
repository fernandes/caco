module Caco::Debian
  class AptRepoAdd < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:name)
    step Caco::Macro::ValidateParamPresence(:url)
    step Caco::Macro::ValidateParamPresence(:release)
    step Caco::Macro::ValidateParamPresence(:component)
    step Caco::Macro::NormalizeParams()

    step :build_repo_content
    step :build_repo_path
    step :write_repo_content

    def build_repo_content(ctx, params:, url:, release:, component:, **)
      ctx[:repo_content] = "deb #{url} #{release} #{component}"
      true
    end

    def build_repo_path(ctx, repo_content:, name:, **)
      ctx[:repo_path] = "/etc/apt/sources.list.d/#{name}.list"
    end

    def write_repo_content(ctx, repo_content:, repo_path:, **)
      result = Caco::FileWriter.(params: {path: repo_path, content: repo_content})
      ctx[:repo_changed] = result[:file_changed]
      result.success?
    end
  end
end
