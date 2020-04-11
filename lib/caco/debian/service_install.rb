module Caco::Debian
  class ServiceInstall < Trailblazer::Operation
    step ->(ctx, name:, **) {
        ctx[:service_path] = "/etc/systemd/system/#{name}.service"
      },
      id: :generate_service_path

    step :generate_template_content

    step Subprocess(Caco::FileWriter),
      input: ->(_ctx, service_path:, template_content:, **) {{
        path: service_path,
        content: template_content
      }}

    step Subprocess(Caco::Executer),
      input: ->(_ctx, **) {{
        command: "systemctl daemon-reload",
      }},
      id: "systemctl_reload"

    def generate_template_content(ctx, description: nil, environment_file: nil, environment_vars: nil, command:, **)
      ctx[:template_content] = Caco::Debian::Cell::Service.(
        command: command,
        description: description,
        environment_file: environment_file,
        environment_vars: environment_vars,
      ).to_s
    end
  end
end
