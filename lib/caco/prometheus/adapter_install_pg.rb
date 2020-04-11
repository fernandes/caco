class Caco::Prometheus::AdapterInstallPg < Trailblazer::Operation
  step Subprocess(Class.new(Caco::Debian::PackageInstall)),
    input: ->(_ctx, postgresql_version:, **) {{
      package: "postgresql-server-dev-#{postgresql_version}"
    }},
    id: :install_postgresql_server_dev

  step Subprocess(Class.new(Caco::Debian::PackageInstall)),
    input: ->(_ctx, postgresql_version:, **) {{
      package: "libpq-dev"
    }},
    id: :install_libpq_dev

  step :check_root
  def check_root(ctx, **)
    ctx[:root] = Settings.prometheus.root
    FileUtils.mkdir_p(Settings.prometheus.root)
  end

  step :build_url
  def build_url(ctx, version:, root:, **)
    ctx[:url] = "https://github.com/timescale/pg_prometheus/archive/#{version}.tar.gz"
    ctx[:dest] = "#{root}/pg_prometheus-#{version}.tar.gz"
    ctx[:current_target] = "#{root}/pg_prometheus-#{version}"
    ctx[:current_link] = "#{root}/pg_prometheus-current"
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

  # Build
  step Subprocess(Class.new(Caco::Executer)),
    input: ->(_ctx, current_link:, **) {{
      command: "test -f #{current_link}/.caco_built"
    }},
    id: :check_caco_built,
    Output(:failure) => Track(:build_pg)

  step Subprocess(Class.new(Caco::Executer)),
    input: ->(_ctx, current_link:, **) {{
      command: "cd #{current_link} && make"
    }},
    id: :build_pg,
    magnetic_to: :build_pg,
    Output(:success) => Track(:build_pg)

  step Subprocess(Class.new(Caco::Executer)),
    input: ->(_ctx, current_link:, **) {{
      command: "touch #{current_link}/.caco_built"
    }},
    id: :mark_as_built,
    magnetic_to: :build_pg

  # Install
  step Subprocess(Class.new(Caco::Executer)),
    input: ->(_ctx, current_link:, **) {{
      command: "test -f #{current_link}/.caco_installed"
    }},
    id: :check_caco_installed,
    Output(:failure) => Track(:install_pg)

  step Subprocess(Class.new(Caco::Executer)),
    input: ->(_ctx, current_link:, **) {{
      command: "cd #{current_link} && make install"
    }},
    id: :install_pg,
    magnetic_to: :install_pg,
    Output(:success) => Track(:install_pg)

  step Subprocess(Class.new(Caco::Executer)),
    input: ->(_ctx, current_link:, **) {{
      command: "touch #{current_link}/.caco_installed"
    }},
    id: :mark_as_installed,
    magnetic_to: :install_pg,
    Output(:success) => Track(:install_pg)

  step :postgresql_shared_library,
    magnetic_to: :install_pg,
    Output(:success) => Track(:install_pg)

  step :postgresql_should_restart,
    magnetic_to: :install_pg

  def postgresql_shared_library(ctx, **)
    Caco::Postgres.add_shared_library("timescaledb")
    Caco::Postgres.add_shared_library("pg_prometheus")
  end

  def postgresql_should_restart(ctx, **)
    Caco::Postgres.should_restart!
  end
end
