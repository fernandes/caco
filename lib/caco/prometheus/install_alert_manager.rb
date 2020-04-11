class Caco::Prometheus::InstallAlertManager < Trailblazer::Operation
  step :check_root
  def check_root(ctx, **)
    ctx[:root] = Settings.prometheus.root
    FileUtils.mkdir_p(Settings.prometheus.root)
  end

  step :build_url
  def build_url(ctx, version:, root:, **)
    ctx[:url] = "https://github.com/prometheus/alertmanager/releases/download/v#{version}/alertmanager-#{version}.linux-amd64.tar.gz"
    ctx[:dest] = "#{root}/alertmanager-#{version}.linux-amd64.tar.gz"
    ctx[:current_target] = "#{root}/alertmanager-#{version}.linux-amd64"
    ctx[:current_link] = "#{root}/alertmanager-current"
    ctx[:config_file_path] = "#{Settings.prometheus.config_root}/alertmanager.yml"
    ctx[:alerts_file_path] = "#{Settings.prometheus.config_root}/alerts.d/alerts.rules"
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
      name: "prometheus-alertmanager",
      command: "#{current_link}/alertmanager --config.file=#{Settings.prometheus.config_root}/alertmanager.yml"
    }}

  step ->(ctx, **) {
      ctx[:content] = Caco::Prometheus::Cell::Conf.({root: Settings.prometheus.config_root}).to_s
    },
    id: :generate_template!

  step Subprocess(Caco::FileWriter),
    input: { content: :content, config_file_path: :path },
    output: { file_changed: :sources_updated },
    id: :write_config_template

  step ->(ctx, **) {
      ctx[:alerts_content] = Caco::Prometheus::Cell::Alerts.().to_s
    },
    id: :generate_alerts_template!

  step Subprocess(Class.new(Caco::FileWriter)),
    input: { alerts_file_path: :path, alerts_content: :content },
    output: { file_changed: :sources_updated },
    id: :write_alerts_template
end
