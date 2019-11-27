class Caco::Debian::ServiceEnable < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:service)
  step Caco::Macro::NormalizeParams()
  step Subprocess(Caco::Executer),
    input:  ->(_ctx, service:, **) do { params: {
      command: "systemctl list-units --full -all | grep -Fq \"#{service}.service\""
    } } end,
    id: :check_service_exist
  step Subprocess(Class.new(Caco::Executer)),
    input:  ->(_ctx, service:, **) do { params: {
      command: "systemctl is-enabled #{service}.service"
    } } end,
    Output(:success) => End(:success),
    Output(:failure) => Track(:success),
    id: :check_service_enabled
  step Subprocess(Class.new(Caco::Executer)),
    input:  ->(_ctx, service:, **) do { params: {
      command: "systemctl enable #{service}.service"
    } } end,
    id: :enable_service
  step :mark_enabled

  def mark_enabled(ctx, **)
    ctx[:enabled] = true
  end
end
