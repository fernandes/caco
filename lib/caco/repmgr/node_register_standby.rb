module Caco::Repmgr
  class NodeRegisterStandby < Trailblazer::Operation
    step Subprocess(Caco::Repmgr::NodeRole),
      input: ->(_ctx, node_name:, **) {{
        node_name: node_name
      }},
      id: :node_role,
      Output(:success) => Id(:check_existing_id),
      Output(:failure) => Track(:success)

    step ->(ctx, node_role:, **) {
        node_role == "standby"
      },
      magnetic_to: nil,
      Output(:success) => End(:success),
      Output(:failure) => End(:failure),
      id: :check_existing_id

    step Subprocess(Class.new(Caco::Executer)),
      input: ->(_ctx, node_name:, **) {{
        command: "su - postgres -c 'repmgr standby register'"
      }},
      id: :repmgr_register_primary
  end
end
