require "test_helper"

class Caco::Prometheus::ExporterInstallTest < Minitest::Test
  def setup
    @old_root = Caco.config.write_files_root
    Caco.config.write_files_root = nil
    Caco::Postgres.clear_shared_library
  end

  def teardown
    Caco.config.write_files_root = @old_root
  end

  def test_install
    version = "0.7.0"

    downloader_stub_request("", url: "https://github.com/wrouesnel/postgres_exporter/releases/download/v#{version}/postgres_exporter_v#{version}_linux-amd64.tar.gz")

    stubbed_file = fixture_file("packs/postgres_exporter_v0.7.0_linux-amd64.tar.gz")
    fakefs do
      returns = [
        [[true, 0, "2"], ["tar tf /opt/prometheus/postgres_exporter_v0.7.0_linux-amd64.tar.gz 2> /dev/null|wc -l"]],
        [[true, 0, ""], ["tar xpf /opt/prometheus/postgres_exporter_v0.7.0_linux-amd64.tar.gz -C /opt/prometheus"]],
        [[true, 0, ""], ["systemctl daemon-reload"]],
      ]

      args = {
        version: version,
        url: "https://github.com/wrouesnel/postgres_exporter/releases/download/v#{version}/postgres_exporter_v#{version}_linux-amd64.tar.gz",
        tar_dest_path: "#{Settings.prometheus.root}/postgres_exporter_v#{version}_linux-amd64.tar.gz",
        tar_unpack_path: "#{Settings.prometheus.root}",
        current_target: "#{Settings.prometheus.root}/postgres_exporter_v#{version}_linux-amd64",
        current_link: "#{Settings.prometheus.root}/postgres_exporter-current",
        environment_vars: [ "DATA_SOURCE_NAME=\"user=prometheus password=oftpix7iyUAx host=127.0.0.1 sslmode=disable\"" ],
        environment_file: nil,
        service_name: "prometheus-exporter-postgres",
        service_command: "/opt/prometheus/postgres_exporter-current/postgres_exporter",
        stubbed_file: stubbed_file
      }
      executer_stub(returns) do
        # Dev.wtf?(described_class, args)
        result = described_class.(args)
        assert result.success?
      end

      # Unpack to dest is asserted with tar xpf command
      assert File.exist?("/opt/prometheus/postgres_exporter_v0.7.0_linux-amd64.tar.gz")
      assert File.symlink?("/opt/prometheus/postgres_exporter-current")
      assert_equal "/opt/prometheus/postgres_exporter_v0.7.0_linux-amd64", File.readlink("/opt/prometheus/postgres_exporter-current")
      assert File.exist?("/etc/systemd/system/prometheus-exporter-postgres.service")

      environment_regexp = Regexp.new("^Environment=DATA_SOURCE_NAME=\"user=prometheus password=oftpix7iyUAx host=127.0.0.1 sslmode=disable\"$")
      assert_match environment_regexp, File.read("/etc/systemd/system/prometheus-exporter-postgres.service")

      command_regexp = Regexp.new("^ExecStart=/opt/prometheus/postgres_exporter-current/postgres_exporter$")
      assert_match command_regexp, File.read("/etc/systemd/system/prometheus-exporter-postgres.service")
    end
  end
end
