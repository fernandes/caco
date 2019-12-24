class Caco::Prometheus::ExporterInstall < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:version)
  step Caco::Macro::ValidateParamPresence(:url)
  step Caco::Macro::ValidateParamPresence(:tar_dest_path)
  step Caco::Macro::ValidateParamPresence(:tar_unpack_path)
  step Caco::Macro::ValidateParamPresence(:current_target)
  step Caco::Macro::ValidateParamPresence(:current_link)
  step Caco::Macro::ValidateParamPresence(:service_name)
  step Caco::Macro::ValidateParamPresence(:service_command)
  step Caco::Macro::NormalizeParams()
  step :check_root
  step Subprocess(Caco::Downloader),
    input:  ->(ctx, params:, url:, tar_dest_path:, **) do {
      params: {
        url: url, dest: tar_dest_path
      },
      stubbed_file: ctx[:stubbed_file]    
    } end
  step Subprocess(Caco::Unpacker),
    input:  ->(ctx, tar_dest_path:, tar_unpack_path:, **) do {
      params: {
        pack: tar_dest_path,
        dest: tar_unpack_path
      }
    } end
  step Subprocess(Caco::FileLink),
    input:  ->(ctx, current_target:, current_link:, **) do {
      params: {
        target: current_target,
        link: current_link
      }
    } end
  step Subprocess(Caco::Debian::ServiceInstall),
    input:  ->(ctx, service_name:, service_command:, params:, **) do {
      params: {
        name: service_name,
        command: service_command,
        environment_vars: params[:environment_vars],
        environment_file: params[:environment_file]
      }
    } end

  def check_root(ctx, **)
    ctx[:root] = Settings.prometheus.root
    FileUtils.mkdir_p(Settings.prometheus.root)
  end
end
