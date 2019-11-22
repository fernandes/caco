require "test_helper"

class Caco::Postgres::InstallTest < Minitest::Test
  def setup
    clean_tmp_path
    Caco::Debian.apt_updated = false
  end

  def test_install_package
    returns = [
      [[false, 1, ""], ["apt-key list|egrep -i 'B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8'"]],
      [[true, 0, ""], ["wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -"]],
      [[true, 0, ""], ["apt-get update"]],
      [[false, 1, ""], ["dpkg -s postgresql-server-12"]],
      [[true, 0, ""], ["apt-get install -y postgresql-server-12"]]
    ]

    executer_stub(returns) do
      # Dev.wtf?(described_class, {})
      result = described_class.()
      assert result.success?

      output = Caco::FileReader.(params: {path: "/etc/apt/sources.list.d/pgdg.list"})[:output]
      repo_content = "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main"
      assert_equal repo_content, output
    end
  end

  def test_install_dev_package
    returns = [
      [[false, 1, ""], ["apt-key list|egrep -i 'B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8'"]],
      [[true, 0, ""], ["wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -"]],
      [[true, 0, ""], ["apt-get update"]],
      [[false, 1, ""], ["dpkg -s postgresql-server-12"]],
      [[true, 0, ""], ["apt-get install -y postgresql-server-12"]],
      [[false, 1, ""], ["dpkg -s postgresql-server-dev-12"]],
      [[true, 0, ""], ["apt-get install -y postgresql-server-dev-12"]]
    ]

    executer_stub(returns) do
      # Dev.wtf?(described_class, {})
      result = described_class.(params: { install_dev_package: true })
      assert result.success?

      output = Caco::FileReader.(params: {path: "/etc/apt/sources.list.d/pgdg.list"})[:output]
      repo_content = "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main"
      assert_equal repo_content, output
    end
  end
end
