require "test_helper"

class Caco::Grafana::InstallTest < Minitest::Test
  def setup
    clean_tmp_path
    Caco::Debian.apt_updated = false
  end

  def test_install_package
    returns = [
      [[false, 1, ""], ["apt-key list|egrep -i '4E40 DDF6 D76E 284A 4A67  80E4 8C8C 34C5 2409 8CB6'"]],
      [[true, 0, ""], ["wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -"]],
      [[true, 0, ""], ["apt-get update"]],
      [[false, 1, ""], ["dpkg -s grafana"]],
      [[true, 0, ""], ["apt-get install -y grafana"]]
    ]

    executer_stub(returns) do
      # Dev.wtf?(described_class, {})
      result = described_class.()
      assert result.success?
    end
  end
end
