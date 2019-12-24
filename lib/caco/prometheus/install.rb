class Caco::Prometheus::Install < Trailblazer::Operation
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
        name: "Prometheus Monitoring File",
        command: "#{current_link}/prometheus --config.file=#{Settings.prometheus.config_root}/prometheus.yml --storage.tsdb.path=#{Settings.prometheus.root}/data"
      }
    } end

  step :generate_template!
  step Subprocess(Caco::FileWriter),
    input: :file_writer_input,
    output: :file_writer_output

    def file_writer_input(original_ctx, config_file_path:, content:, **)
      { params: { path: config_file_path, content: content } }
    end
  
    def file_writer_output(scoped_ctx, file_created:, file_changed:, **)
      { sources_updated: file_changed }
    end

  def check_root(ctx, **)
    ctx[:root] = Settings.prometheus.root
    FileUtils.mkdir_p(Settings.prometheus.root)
  end

  def build_url(ctx, version:, root:, **)
    ctx[:url] = "https://github.com/prometheus/prometheus/releases/download/v#{version}/prometheus-#{version}.linux-amd64.tar.gz"
    ctx[:dest] = "#{root}/prometheus-#{version}.linux-amd64.tar.gz"
    ctx[:current_target] = "#{root}/prometheus-#{version}.linux-amd64"
    ctx[:current_link] = "#{root}/prometheus-current"
    ctx[:config_file_path] = "#{Settings.prometheus.config_root}/prometheus.yml"
  end

  def generate_template!(ctx, **)
    ctx[:content] = Caco::Prometheus::Cell::Conf.({root: Settings.prometheus.config_root}).to_s
  end
end
