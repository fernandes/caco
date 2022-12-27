class Caco::Prometheus::Install < Trailblazer::Operation
  step :check_root
  def check_root(ctx, **)
    ctx[:root] = Settings.prometheus.root
    FileUtils.mkdir_p(Settings.prometheus.root)
  end

  step :build_url
  def build_url(ctx, version:, root:, **)
    ctx[:url] = "https://github.com/prometheus/prometheus/releases/download/v#{version}/prometheus-#{version}.linux-amd64.tar.gz"
    ctx[:dest] = "#{root}/prometheus-#{version}.linux-amd64.tar.gz"
    ctx[:current_target] = "#{root}/prometheus-#{version}.linux-amd64"
    ctx[:current_link] = "#{root}/prometheus-current"
    ctx[:config_file_path] = "#{Settings.prometheus.config_root}/prometheus.yml"
  end

  step Subprocess(Caco::Downloader),
    input: ->(ctx, url:, dest:, **) {{
      url: url,
      dest: dest,
      stubbed_file: ctx[:stubbed_file]    
    }}

  step Subprocess(Caco::Unpacker),
    input: ->(ctx, root:, dest:, **) {{
      pack: dest,
      dest: root
    }}

  step Subprocess(Caco::FileLink),
    input: ->(ctx, current_target:, current_link:, **) {{
      target: current_target,
      link: current_link
    }}

  step Subprocess(Caco::Debian::ServiceInstall),
    input: ->(ctx, current_link:, **) {{
      name: "prometheus",
      command: "#{current_link}/prometheus --config.file=#{Settings.prometheus.config_root}/prometheus.yml --storage.tsdb.path=#{Settings.prometheus.root}/data"
    }}

  step ->(ctx, **) {
      ctx[:content] = Caco::Prometheus::Cell::Conf.({root: Settings.prometheus.config_root}).to_s
    },
    id: :generate_template!

  step :write_file

  def write_file(ctx, config_file_path:, content:, **)
    result = file config_file_path, content: content

    ctx[:sources_updated] = result[:changed]
  end
end
