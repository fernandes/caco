module Caco::Repmgr
  class NodeRegistered < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:node_name)
    step Caco::Macro::NormalizeParams()

    step Subprocess(Caco::Executer),
      input:  ->(_ctx, node_name:, **) do { params: {
        command: "su - postgres -c 'repmgr cluster show --compact'"
      } } end,
      id: :repmgr_cluster_show
    step :verify_node

    def verify_node(ctx, node_name:, output:, **)
      # ctx to be used in other operations
      ctx[:node_registered] = output.match?(/^\s+[0-9]{1,}\s+\|\s+#{node_name}\s+\|/)
    end
  end
end
