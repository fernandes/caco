require "test_helper"

class Caco::Barman::InstallTest < Minitest::Test
  def setup
    Caco.config.write_files = false
  end

  def test_install_package
    returns = [
      [[false, 1, ""], ["apt-key list|egrep -i '8565 305C EA7D 0B66 4933  D250 9904 CD4B D6BA F0C3'"]],
      [[true, 0, ""], ["wget -q -O - https://dl.2ndquadrant.com/gpg-key.asc | apt-key add -"]],
      [[true, 0, ""], ["apt-get update"]],
      [[false, 1, ""], ["dpkg -s barman"]],
      [[true, 0, ""], ["apt-get install -y barman"]]
    ]

    executer_stub(returns) do
      # Dev.wtf?(described_class, {})
      result = described_class.()
      assert result.success?
    end
  end
end
