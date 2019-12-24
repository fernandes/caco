class Caco::Prometheus::InstallAlertManager < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:version)
  step Caco::Macro::NormalizeParams()
  step :check_root
  step :build_url
  step Subprocess(Caco::Downloader),
    input:  ->(ctx, params:, url:, dest:, **) do {
      params: {
        url: url, dest: dest
      },
      stubbed_file: ctx[:stubbed_file]    
    } end
  step Subprocess(Caco::Unpacker),
    input:  ->(ctx, root:, dest:, **) do {
      params: {
        pack: dest,
        dest: root
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
    input:  ->(ctx, current_link:, **) do {
      params: {
        name: "prometheus-alertmanager",
        command: "#{current_link}/alertmanager --config.file=#{Settings.prometheus.config_root}/alertmanager.yml"
      }
    } end

  step :generate_template!
  step Subprocess(Caco::FileWriter),
    input: :file_writer_input,
    output: :file_writer_output,
    id: :write_config_template

    def file_writer_input(original_ctx, config_file_path:, content:, **)
      { params: { path: config_file_path, content: content } }
    end
  
    def file_writer_output(scoped_ctx, file_created:, file_changed:, **)
      { sources_updated: file_changed }
    end
  
  step :generate_alerts_template!
  step Subprocess(Class.new(Caco::FileWriter)),
    input: :file_writer_alerts_input,
    output: :file_writer_alerts_output,
    id: :write_alerts_template

    def file_writer_alerts_input(original_ctx, alerts_file_path:, alerts_content:, **)
      { params: { path: alerts_file_path, content: alerts_content } }
    end
  
    def file_writer_alerts_output(scoped_ctx, file_created:, file_changed:, **)
      { sources_updated: file_changed }
    end

  def check_root(ctx, **)
    ctx[:root] = Settings.prometheus.root
    FileUtils.mkdir_p(Settings.prometheus.root)
  end

  def build_url(ctx, version:, root:, **)
    ctx[:url] = "https://github.com/prometheus/alertmanager/releases/download/v#{version}/alertmanager-#{version}.linux-amd64.tar.gz"
    ctx[:dest] = "#{root}/alertmanager-#{version}.linux-amd64.tar.gz"
    ctx[:current_target] = "#{root}/alertmanager-#{version}.linux-amd64"
    ctx[:current_link] = "#{root}/alertmanager-current"
    ctx[:config_file_path] = "#{Settings.prometheus.config_root}/alertmanager.yml"
    ctx[:alerts_file_path] = "#{Settings.prometheus.config_root}/alerts.d/alerts.rules"
  end

  def generate_template!(ctx, **)
    ctx[:content] = Caco::Prometheus::Cell::Conf.({root: Settings.prometheus.config_root}).to_s
  end

  def generate_alerts_template!(ctx, **)
    ctx[:alerts_content] = Caco::Prometheus::Cell::Alerts.().to_s
  end
end
