require "test_helper"

class Caco::Prometheus::AdapterInstallPostgresqlTest < Minitest::Test
  def setup
    @old_root = Caco.config.write_files_root
    Caco.config.write_files_root = nil
    Caco::Postgres.clear_shared_library
  end

  def teardown
    Caco.config.write_files_root = @old_root
  end

  def test_install
    version = "0.6.0"
    downloader_stub_request("", url: "https://github.com/timescale/prometheus-postgresql-adapter/releases/download/v#{version}/prometheus-postgresql-adapter-#{version}-linux-amd64.tar.gz")

    stubbed_file = fixture_file("packs/prometheus-postgresql-adapter-0.6.0-linux-amd64.tar.gz")
    fakefs do
      returns = [
        [[true, 0, "2"], ["tar tf /opt/prometheus/prometheus-postgresql-adapter-0.6.0-linux-amd64.tar.gz 2> /dev/null|wc -l"]],
        [[true, 0, ""], ["tar xpf /opt/prometheus/prometheus-postgresql-adapter-0.6.0-linux-amd64.tar.gz -C /opt/prometheus/postgresql-adapter-0.6.0.linux-amd64"]],
        [[true, 0, ""], ["systemctl daemon-reload"]]
      ]
      
      args = {
        version: version,
        database: "prometheus",
        host: "127.0.0.1",
        username: "prometheus",
        password: "secret",
        stubbed_file: stubbed_file
      }
      executer_stub(returns) do
        # Dev.wtf?(described_class, args)
        result = described_class.(args)
        assert result.success?
      end

      # Unpack to dest is asserted with tar xpf command
      assert File.exist?("/opt/prometheus/prometheus-postgresql-adapter-0.6.0-linux-amd64.tar.gz")
      assert File.exist?("/opt/prometheus/postgresql-adapter-0.6.0.linux-amd64")
      assert File.symlink?("/opt/prometheus/postgresql-adapter-current")
      assert_equal "/opt/prometheus/postgresql-adapter-0.6.0.linux-amd64", File.readlink("/opt/prometheus/postgresql-adapter-current")
      assert File.exist?("/etc/systemd/system/prometheus-adapter-postgresql.service")

      command_regexp = Regexp.new("^ExecStart=/opt/prometheus/postgresql-adapter-current/prometheus-postgresql-adapter -pg-database prometheus -pg-host 127.0.0.1 -pg-user prometheus -pg-password secret -log-level warn$")
      assert_match command_regexp, File.read("/etc/systemd/system/prometheus-adapter-postgresql.service")
    end
  end
end
