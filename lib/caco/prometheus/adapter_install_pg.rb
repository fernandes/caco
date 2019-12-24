class Caco::Prometheus::AdapterInstallPg < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:version)
  step Caco::Macro::ValidateParamPresence(:postgresql_version)
  step Caco::Macro::NormalizeParams()
  step Subprocess(Class.new(Caco::Debian::PackageInstall)),
    input:  ->(_ctx, postgresql_version:, **) do { params: {
      package: "postgresql-server-dev-#{postgresql_version}"
    }} end,
    id: :install_postgresql_server_dev
  step Subprocess(Class.new(Caco::Debian::PackageInstall)),
    input:  ->(_ctx, postgresql_version:, **) do { params: {
      package: "libpq-dev"
    }} end,
    id: :install_libpq_dev
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

  # Build
  step Subprocess(Class.new(Caco::Executer)),
    input:  ->(_ctx, current_link:, **) do { params: {
      command: "test -f #{current_link}/.caco_built"
    } } end,
    id: :check_caco_built,
    Output(:failure) => Track(:build_pg)

  step Subprocess(Class.new(Caco::Executer)),
    input:  ->(_ctx, current_link:, **) do { params: {
      command: "cd #{current_link} && make"
    } } end,
    id: :build_pg,
    magnetic_to: :build_pg,
    Output(:success) => Track(:build_pg)
  
  step Subprocess(Class.new(Caco::Executer)),
    input:  ->(_ctx, current_link:, **) do { params: {
      command: "touch #{current_link}/.caco_built"
    } } end,
    id: :mark_as_built,
    magnetic_to: :build_pg
  
  # Install
  step Subprocess(Class.new(Caco::Executer)),
    input:  ->(_ctx, current_link:, **) do { params: {
      command: "test -f #{current_link}/.caco_installed"
    } } end,
    id: :check_caco_installed,
    Output(:failure) => Track(:install_pg)

  step Subprocess(Class.new(Caco::Executer)),
    input:  ->(_ctx, current_link:, **) do { params: {
      command: "cd #{current_link} && make install"
    } } end,
    id: :install_pg,
    magnetic_to: :install_pg,
    Output(:success) => Track(:install_pg)
  
  step Subprocess(Class.new(Caco::Executer)),
    input:  ->(_ctx, current_link:, **) do { params: {
      command: "touch #{current_link}/.caco_installed"
    } } end,
    id: :mark_as_installed,
    magnetic_to: :install_pg,
    Output(:success) => Track(:install_pg)
  
  step :postgresql_shared_library,
    magnetic_to: :install_pg,
    Output(:success) => Track(:install_pg)
  
  step :postgresql_should_restart,
    magnetic_to: :install_pg

  def check_root(ctx, **)
    ctx[:root] = Settings.prometheus.root
    FileUtils.mkdir_p(Settings.prometheus.root)
  end

  def build_url(ctx, version:, root:, **)
    ctx[:url] = "https://github.com/timescale/pg_prometheus/archive/#{version}.tar.gz"
    ctx[:dest] = "#{root}/pg_prometheus-#{version}.tar.gz"
    ctx[:current_target] = "#{root}/pg_prometheus-#{version}"
    ctx[:current_link] = "#{root}/pg_prometheus-current"
  end

  def postgresql_shared_library(ctx, params:, **)
    Caco::Postgres.add_shared_library("timescaledb")
    Caco::Postgres.add_shared_library("pg_prometheus")
  end

  def postgresql_should_restart(ctx, params:, **)
    Caco::Postgres.should_restart!
  end
end
