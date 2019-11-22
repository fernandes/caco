require "test_helper"

class Caco::Haproxy::InstallTest < Minitest::Test
  def setup
    clean_tmp_path
    Caco::Debian.apt_updated = false
  end

  def test_install_package
    returns = [
      [[true, 0, ""], ["apt-get update"]],
      [[false, 1, ""], ["dpkg -s haproxy"]],
      [[true, 0, ""], ["apt-get install -y haproxy"]]
    ]

    executer_stub(returns) do
      # Dev.wtf?(described_class, {})
      result = described_class.()
      assert result.success?
    end
  end
end
