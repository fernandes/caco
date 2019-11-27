module Caco::Repmgr
  class NodeRegisterPrimary < Trailblazer::Operation
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
    step :verify_any_primary,
      Output(:success) => End(:failure),
      Output(:failure) => Track(:success)

    def verify_any_primary(ctx, node_name:, output:, **)
      output.match?(/^\s+[0-9]{1,}\s+\|\s(?!#{node_name})[^\s]+\s+\|\s+primary\s+\|/)
    end

    step Subprocess(Class.new(Caco::Executer)),
      input:  ->(_ctx, node_name:, **) do { params: {
        command: "su - postgres -c 'repmgr primary register'"
      } } end,
      id: :repmgr_register_primary
    
    def check_existing_id(ctx, node_role:, **)
      return true if node_role == "primary"
      false
    end
  end
end
