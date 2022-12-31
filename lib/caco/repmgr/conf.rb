module Caco::Repmgr
  class Conf < Trailblazer::Operation
    step ->(ctx, **) {
        ctx[:path] = "/etc/repmgr.conf"
      },
      id: :build_path

    step :build_content

    step :write_file,
      input: ->(_ctx, path:, content:, **) {{
        path: path,
        content: content
      }}


    def write_file(ctx, path:, content:, **)
      result = Caco.file path, content: content

      ctx[:created] = result[:created]
      ctx[:changed] = result[:changed]
      true
    end

    def build_content(ctx, node_id:, node_name:, postgres_version:, **)
      ctx[:content] = Caco::Repmgr::Cell::Conf.(
        node_id: node_id,
        node_name: node_name,
        postgres_version: postgres_version
      ).to_s
    end
  end
end
