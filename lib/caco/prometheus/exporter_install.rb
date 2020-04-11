class Caco::Prometheus::ExporterInstall < Trailblazer::Operation
  step :check_root

  step Subprocess(Caco::Downloader),
    input: ->(ctx, url:, tar_dest_path:, **) {{
      url: url,
      dest: tar_dest_path,
      stubbed_file: ctx[:stubbed_file]    
    }}

  step Subprocess(Caco::Unpacker),
    input: ->(ctx, tar_dest_path:, tar_unpack_path:, **) {{
      pack: tar_dest_path,
      dest: tar_unpack_path
    }}

  step Subprocess(Caco::FileLink),
    input: ->(ctx, current_target:, current_link:, **) {{
      target: current_target,
      link: current_link
    }}

  step Subprocess(Caco::Debian::ServiceInstall),
    input: ->(ctx, service_name:, service_command:, environment_vars: nil, environment_file: nil, **) {{
      name: service_name,
      command: service_command,
      environment_vars: environment_vars,
      environment_file: environment_file
    }}

  def check_root(ctx, **)
    ctx[:root] = Settings.prometheus.root
    FileUtils.mkdir_p(Settings.prometheus.root)
  end
end
