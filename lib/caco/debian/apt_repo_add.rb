module Caco::Debian
  class AptRepoAdd < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:name)
    step Caco::Macro::ValidateParamPresence(:url)
    step Caco::Macro::ValidateParamPresence(:release)
    step Caco::Macro::ValidateParamPresence(:component)
    step Caco::Macro::NormalizeParams()

    step :build_repo_content
    step :build_repo_path
    step Subprocess(Caco::FileWriter),
      input: :file_writer_input,
      output: :file_writer_output

    def build_repo_content(ctx, params:, url:, release:, component:, **)
      ctx[:content] = "deb #{url} #{release} #{component}"
      true
    end

    def build_repo_path(ctx, name:, **)
      ctx[:path] = "/etc/apt/sources.list.d/#{name}.list"
    end

    private
      def file_writer_input(original_ctx, **)
        { params: { path: original_ctx[:path], content: original_ctx[:content] } }
      end
    
      def file_writer_output(scoped_ctx, file_created:, file_changed:, **)
        { repo_created: file_created, repo_changed: file_changed }
      end
  end
end
