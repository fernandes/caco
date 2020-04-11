module Caco::Repmgr
  class NodeRegistered < Trailblazer::Operation
    step Subprocess(Caco::Executer),
      input: ->(_ctx, node_name:, **) {{
        command: "su - postgres -c 'repmgr cluster show --compact'"
      }},
      id: :repmgr_cluster_show

    step ->(ctx, node_name:, output:, **) {
        # set to ctx so can be used in other operations
        ctx[:node_registered] = output.match?(/^\s+[0-9]{1,}\s+\|\s+#{node_name}\s+\|/)
      },
      id: :verify_node
  end
end
