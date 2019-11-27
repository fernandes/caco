module Caco::Repmgr
  class Conf < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:node_id)
    step Caco::Macro::ValidateParamPresence(:node_name)
    step Caco::Macro::ValidateParamPresence(:postgres_version)
    step Caco::Macro::NormalizeParams()
    step :build_path
    step :build_content
    step Subprocess(Caco::FileWriter),
    input:  ->(_ctx, path:, content:, **) do { params: {
      path: path,
      content: content
    } } end,
    output: {file_created: :created, file_changed: :changed}


    def build_path(ctx, **)
      ctx[:path] = "/etc/repmgr.conf"
    end

    def build_content(ctx, node_id:, node_name:, postgres_version:, **)
      ctx[:content] = Caco::Repmgr::Cell::Conf.(
        node_id: node_id,
        node_name: node_name,
        postgres_version: postgres_version
      ).to_s
      true
    end
  end
end
