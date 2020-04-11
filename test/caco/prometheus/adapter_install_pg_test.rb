require "test_helper"

class Caco::Prometheus::AdapterInstallPgTest < Minitest::Test
  def setup
    @old_root = Caco.config.write_files_root
    Caco.config.write_files_root = nil
    Caco::Postgres.clear_shared_library
  end

  def teardown
    Caco.config.write_files_root = @old_root
  end

  def test_install
    version = "0.2.2"
    downloader_stub_request("", url: "https://github.com/timescale/pg_prometheus/archive/#{version}.tar.gz")

    stubbed_file = fixture_file("packs/pg_prometheus-0.2.2.tar.gz")
    fakefs do
      returns = [
        [[false, 1, ""], ['dpkg -s postgresql-server-dev-11']],
        [[true, 0, ""], ["apt-get install -y postgresql-server-dev-11"]],
        [[false, 1, ""], ['dpkg -s libpq-dev']],
        [[true, 0, ""], ["apt-get install -y libpq-dev"]],
        [[true, 0, "2"], ["tar tf /opt/prometheus/pg_prometheus-0.2.2.tar.gz 2> /dev/null|wc -l"]],
        [[true, 0, ""], ["tar xpf /opt/prometheus/pg_prometheus-0.2.2.tar.gz -C /opt/prometheus"]],
        [[false, 1, ""], ["test -f /opt/prometheus/pg_prometheus-current/.caco_built"]],
        [[true, 0, ""], ["cd /opt/prometheus/pg_prometheus-current && make"]],
        [[true, 0, ""], ["touch /opt/prometheus/pg_prometheus-current/.caco_built"]],
        [[false, 1, ""], ["test -f /opt/prometheus/pg_prometheus-current/.caco_installed"]],
        [[true, 0, ""], ["cd /opt/prometheus/pg_prometheus-current && make install"]],
        [[true, 0, ""], ["touch /opt/prometheus/pg_prometheus-current/.caco_installed"]],
      ]
      
      args = { version: version, postgresql_version: 11, stubbed_file: stubbed_file }
      executer_stub(returns) do
        # Dev.wtf?(described_class, args)
        result = described_class.(args)
        assert result.success?
      end

      # Unpack to dest is asserted with tar xpf command
      assert File.exist?("/opt/prometheus/pg_prometheus-0.2.2.tar.gz")
      assert File.symlink?("/opt/prometheus/pg_prometheus-current")
      assert_equal "/opt/prometheus/pg_prometheus-0.2.2", File.readlink("/opt/prometheus/pg_prometheus-current")

      assert_equal "timescaledb, pg_prometheus", Caco::Postgres.shared_libraries
      assert Caco::Postgres.should_restart?
    end
  end
end
