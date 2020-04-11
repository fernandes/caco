module Caco::Debian
  class ServiceEnable < Trailblazer::Operation
    step Subprocess(Caco::Executer),
      input: ->(_ctx, service:, **) {{
        command: "systemctl list-units --full -all | grep -Fq \"#{service}.service\""
      }},
      id: :check_service_exist

    step Subprocess(Class.new(Caco::Executer)),
      Output(:success) => End(:success),
      Output(:failure) => Track(:success),
      input: ->(_ctx, service:, **) {{
        command: "systemctl is-enabled #{service}.service"
      }},
      id: :check_service_enabled

    step Subprocess(Class.new(Caco::Executer)),
      input: ->(_ctx, service:, **) {{
        command: "systemctl enable #{service}.service"
      }},
      id: :enable_service

    step ->(ctx, **) { ctx[:enabled] = true },
      id: :mark_enabled
  end
end
