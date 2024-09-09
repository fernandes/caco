require "test_helper"

class Caco::Prometheus::InstallTest < Minitest::Test
  def setup
    @old_root = Caco.config.write_files_root
    Caco.config.write_files_root = nil
  end

  def teardown
    Caco.config.write_files_root = @old_root
  end

  def test_install
    version = "2.14.0"
    downloader_stub_request("", url: "https://github.com/prometheus/prometheus/releases/download/v#{version}/prometheus-#{version}.linux-amd64.tar.gz")

    stubbed_file = fixture_file("packs/prometheus-2.14.0.linux-amd64.tar.gz")
    fakefs do
      returns = [
        [[true, 0, "2"], ["tar tf /opt/prometheus/prometheus-2.14.0.linux-amd64.tar.gz 2> /dev/null|wc -l"]],
        [[true, 0, ""], ["tar xpf /opt/prometheus/prometheus-2.14.0.linux-amd64.tar.gz -C /opt/prometheus"]],
        [[true, 0, ""], ["systemctl daemon-reload"]]
      ]

      args = {version: version, stubbed_file: stubbed_file}
      executer_stub(returns) do
        # Dev.wtf?(described_class, args)
        result = described_class.call(**args)
        assert result.success?
      end

      # Unpack to dest is asserted with tar xpf command
      assert File.exist?("/opt/prometheus/prometheus-2.14.0.linux-amd64.tar.gz")
      assert File.symlink?("/opt/prometheus/prometheus-current")
      assert_equal "/opt/prometheus/prometheus-2.14.0.linux-amd64", File.readlink("/opt/prometheus/prometheus-current")
      assert File.exist?("/etc/prometheus/prometheus.yml")
      assert File.exist?("/etc/systemd/system/prometheus.service")
      command_regexp = Regexp.new("^ExecStart=/opt/prometheus/prometheus-current/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/opt/prometheus/data$")
      assert_match command_regexp, File.read("/etc/systemd/system/prometheus.service")
    end
  end
end
