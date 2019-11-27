module Caco::Repmgr
  class NodeRegisterStandby < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:node_name)
    step Caco::Macro::NormalizeParams()

    step Subprocess(Caco::Repmgr::NodeRole),
      input:  ->(_ctx, node_name:, **) do { params: {
        node_name: node_name
      } } end,
      id: :node_role,
      Output(:success) => Id(:check_existing_id),
      Output(:failure) => Track(:success)
    step :check_existing_id, magnetic_to: nil,
      Output(:success) => End(:success),
      Output(:failure) => End(:failure)

    step Subprocess(Class.new(Caco::Executer)),
      input:  ->(_ctx, node_name:, **) do { params: {
        command: "su - postgres -c 'repmgr standby register'"
      } } end,
      id: :repmgr_register_primary
    
    def check_existing_id(ctx, node_role:, **)
      return true if node_role == "standby"
      false
    end
  end
end
