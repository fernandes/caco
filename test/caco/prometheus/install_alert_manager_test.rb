require "test_helper"

class Caco::Prometheus::InstallAlertManagerTest < Minitest::Test
  def setup
    @old_root = Caco.config.write_files_root
    Caco.config.write_files_root = nil
  end

  def teardown
    Caco.config.write_files_root = @old_root
  end

  def test_install
    version = "0.19.0"
    downloader_stub_request("", url: "https://github.com/prometheus/alertmanager/releases/download/v#{version}/alertmanager-#{version}.linux-amd64.tar.gz")

    stubbed_file = fixture_file("packs/alertmanager-0.19.0.linux-amd64.tar.gz")
    fakefs do
      returns = [
        [[true, 0, "2"], ["tar tf /opt/prometheus/alertmanager-0.19.0.linux-amd64.tar.gz 2> /dev/null|wc -l"]],
        [[true, 0, ""], ["tar xpf /opt/prometheus/alertmanager-0.19.0.linux-amd64.tar.gz -C /opt/prometheus"]],
        [[true, 0, ""], ["systemctl daemon-reload"]],
      ]
      
      args = {params: {version: version}, stubbed_file: stubbed_file}
      executer_stub(returns) do
        # Dev.wtf?(described_class, args)
        result = described_class.(args)
        assert result.success?
      end

      # Unpack to dest is asserted with tar xpf command
      assert File.exist?("/opt/prometheus/alertmanager-0.19.0.linux-amd64.tar.gz")
      assert File.symlink?("/opt/prometheus/alertmanager-current")
      assert_equal "/opt/prometheus/alertmanager-0.19.0.linux-amd64", File.readlink("/opt/prometheus/alertmanager-current")
      assert File.exist?("/etc/prometheus/alertmanager.yml")
      assert File.exist?("/etc/prometheus/alerts.d/alerts.rules")
      assert File.exist?("/etc/systemd/system/prometheus-alertmanager.service")

      command_regexp = Regexp.new("^ExecStart=/opt/prometheus/alertmanager-current/alertmanager --config.file=/etc/prometheus/alertmanager.yml$")
      assert_match command_regexp, File.read("/etc/systemd/system/prometheus-alertmanager.service")
    end
  end
end
