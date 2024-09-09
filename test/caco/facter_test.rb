require "test_helper"

class Caco::FacterTest < Minitest::Test
  def test_fetch_data
    described_class.use_fake(fake_json_data) do
      assert_equal "UTC", described_class.call("timezone")
    end
  end

  def test_fetch_data_multiple_items
    described_class.use_fake(fake_json_data) do
      assert_equal 174370, described_class.call("system_uptime", "seconds")
    end
  end

  def test_key_not_found
    described_class.use_fake(fake_json_data) do
      err = assert_raises described_class::KeyNotFoundError do
        described_class.call("unknown_key")
      end
      assert_match(/unknown_key not found/, err.message)
    end
  end

  def test_with_real_data
    described_class.use_fake(nil) do
      described_class.stub :external_facter_data, stubbed_json_data do
        assert_equal "-03", described_class.call("timezone")
      end
    end
  end

  def test_data_set_on_test_helper
    assert_equal "America/Sao_Paulo", described_class.call("timezone")
  end

  def fake_json_data
    {
      "system_uptime" => {
        "days" => 2,
        "hours" => 48,
        "seconds" => 174370,
        "uptime" => "2 days"
      },
      "timezone" => "UTC",
      "virtual" => "virtualbox"
    }
  end

  def stubbed_json_data
    {
      "system_uptime" => {
        "days" => 2,
        "hours" => 48,
        "seconds" => 174370,
        "uptime" => "2 days"
      },
      "timezone" => "-03",
      "virtual" => "virtualbox"
    }.to_json
  end
end
