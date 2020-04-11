class Caco::Prometheus::AdapterInstallPostgresql < Trailblazer::Operation
  step :check_root
  step :build_url
  step :mkdir_target

  step Subprocess(Caco::Downloader),
    input: ->(ctx, url:, dest:, **) {{
      url: url,
      dest: dest,
      stubbed_file: ctx[:stubbed_file]    
    }}

  step Subprocess(Caco::Unpacker),
    input: ->(ctx, adapter_root:, dest:, **) {{
      pack: dest,
      dest: adapter_root
    }}

  step Subprocess(Caco::FileLink),
    input: ->(ctx, current_target:, current_link:, **) {{
      target: current_target,
      link: current_link
    }}

  step Subprocess(Caco::Debian::ServiceInstall),
    input: ->(ctx, current_link:, database:, host:, username:, password:, **) {{
      name: "prometheus-adapter-postgresql",
      command: "#{current_link}/prometheus-postgresql-adapter -pg-database #{database} -pg-host #{host} -pg-user #{username} -pg-password #{password} -log-level warn"
    }}

  def check_root(ctx, version:, **)
    ctx[:root] = Settings.prometheus.root
    ctx[:adapter_root] = "#{Settings.prometheus.root}/postgresql-adapter-#{version}.linux-amd64"
    FileUtils.mkdir_p(ctx[:adapter_root])
  end

  def build_url(ctx, version:, root:, adapter_root:, **)
    ctx[:url] = "https://github.com/timescale/prometheus-postgresql-adapter/releases/download/v#{version}/prometheus-postgresql-adapter-#{version}-linux-amd64.tar.gz"
    ctx[:dest] = "#{root}/prometheus-postgresql-adapter-#{version}-linux-amd64.tar.gz"
    ctx[:current_target] = adapter_root
    ctx[:current_link] = "#{root}/postgresql-adapter-current"
  end

  def mkdir_target(ctx, current_target:, **)
    FileUtils.mkdir_p(current_target)
  end
end
