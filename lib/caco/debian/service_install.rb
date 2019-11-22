module Caco::Debian
  class ServiceInstall < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:name)
    step Caco::Macro::ValidateParamPresence(:command)
    step Caco::Macro::NormalizeParams()
    step :generate_service_path
    step :generate_template_content
    step Subprocess(Caco::FileWriter),
      input:  ->(_ctx, service_path:, template_content:, **) do { params: {
        path: service_path,
        content: template_content
      } } end
    step Subprocess(Caco::Executer),
      input:  ->(_ctx, **) do { params: {
        command: "systemctl daemon-reload",
      } } end,
      id: "systemctl_reload"
  
    def generate_service_path(ctx, name:, **)
      ctx[:service_path] = "/etc/systemd/system/#{name}.service"
    end

    def generate_template_content(ctx, command:, params:, **)
      ctx[:template_content] = Caco::Debian::Cell::Service.(
        command: command,
        description: params[:description],
        environment_file: params[:environment_file],
        environment_vars: params[:environment_vars],
      ).to_s
    end
  end
end
