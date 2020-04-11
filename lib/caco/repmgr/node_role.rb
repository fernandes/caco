module Caco::Repmgr
  class NodeRole < Trailblazer::Operation
    step Subprocess(NodeRegistered),
      input: ->(_ctx, node_name:, **) {{
        node_name: node_name
      }},
      id: :node_registered

    step :verify_role

    def verify_role(ctx, node_name:, output:, **)
      match = output.match(/^\s+[0-9]{1,}\s+\|\s+db1\s+\|\s+([^\s]+)\s+\|/)
      return false unless match

      ctx[:node_role] = match[1]
    end
  end
end
