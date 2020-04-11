require "test_helper"

class Caco::Repmgr::InstallTest < Minitest::Test
  def setup
    clean_tmp_path
    Caco::Debian.apt_updated = false
  end

  def test_install_package
    returns = [
      [[false, 1, ""], ["apt-key list|egrep -i '8565 305C EA7D 0B66 4933  D250 9904 CD4B D6BA F0C3'"]],
      [[true, 0, ""], ["wget -q -O - https://dl.2ndquadrant.com/gpg-key.asc | apt-key add -"]],
      [[true, 0, ""], ["apt-get update"]],
      [[false, 1, ""], ["dpkg -s repmgr"]],
      [[true, 0, ""], ["apt-get install -y repmgr"]]
    ]

    executer_stub(returns) do
      # Dev.wtf?(described_class, {})
      result = described_class.(postgres_version: "11")
      assert result.success?

      output = Caco::FileReader.(path: "/etc/apt/sources.list.d/2ndquadrant-dl-default-release.list")[:output]
      repo_content = "deb https://dl.2ndquadrant.com/default/release/apt stretch-2ndquadrant main"
      assert_equal repo_content, output
    end
  end
end
