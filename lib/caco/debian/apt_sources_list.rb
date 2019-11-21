module Caco::Debian
  class AptSourcesList < Trailblazer::Operation
    step Caco::Macro::NormalizeParams()
    step :generate_content
    step :build_path
    step Subprocess(Caco::FileWriter),
      input: :file_writer_input,
      output: :file_writer_output

    def generate_content(ctx, params:, **)
      ctx[:content] = Caco::Debian::Cell::SourcesList.(mirror_url: params[:mirror_url]).to_s
    end

    def build_path(ctx, **)
      ctx[:path] = "/etc/apt/sources.list"
    end

    private
      def file_writer_input(original_ctx, **)
        { params: { path: original_ctx[:path], content: original_ctx[:content] } }
      end
    
      def file_writer_output(scoped_ctx, file_created:, file_changed:, **)
        { sources_updated: file_changed }
      end
  end
end
