require "test_helper"

class Caco::Timescale::InstallTest < Minitest::Test
  def setup
    clean_tmp_path
    Caco::Debian.apt_updated = false
  end

  def test_install_package
    returns = [
      [[false, 1, ""], ["apt-key list|egrep -i '1005 FB68 604C E9B8 F687  9CF7 59F1 8EDF 47F2 4417'"]],
      [[true, 0, ""], ["wget -q -O - https://packagecloud.io/timescale/timescaledb/gpgkey | apt-key add -"]],
      [[true, 0, ""], ["apt-get update"]],
      [[false, 1, ""], ["dpkg -s timescaledb-postgresql-11"]],
      [[true, 0, ""], ["apt-get install -y timescaledb-postgresql-11"]]
    ]

    executer_stub(returns) do
      # Dev.wtf?(described_class, {})
      result = described_class.(postgres_version: "11")
      assert result.success?

      output = Caco::FileReader.(path: "/etc/apt/sources.list.d/timescale.list")[:output]
      repo_content = "deb https://packagecloud.io/timescale/timescaledb/debian/ stretch main"
      assert_equal repo_content, output
    end
  end
end
