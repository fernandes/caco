require "test_helper"

class Caco::Debian::AptKeyInstallTest < Minitest::Test
  def setup
    @key_url = "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
    @key_fingerprint = 'B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8'
  end

  def test_install_new_key
    returns = [
      [[false, 1, ""], ["apt-key list|egrep -i 'B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8'"]],
      [[true, 0, ""], ["wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -"]]
    ]

    executer_stub(returns) do
      params = { url: @key_url, fingerprint: @key_fingerprint }
      result = described_class.(params)
      assert result[:apt_key_executed]
      assert result.success?
    end
  end

  def test_install_existing_key
    returns = [
      [[true, 0, ""], ["apt-key list|egrep -i 'B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8'"]],
    ]

    executer_stub(returns) do
      params = { url: @key_url, fingerprint: @key_fingerprint }
      result = described_class.(params)
      refute result[:apt_key_executed]
      assert result.success?
    end
  end
end
