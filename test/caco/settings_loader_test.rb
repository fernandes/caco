require "test_helper"

class Caco::SettingsLoaderTest < Minitest::Test
  def setup
    Caco::SettingsLoader.(params: {
      keys_path: Caco.root.join("test", "fixtures", "keys"),
      data_path: Caco.root.join("test", "fixtures", "data")
    })
  end

  def teardown
  end

  def test_settings_load_common_values
    assert_equal "bar", Settings.foo
  end

  def test_settings_load_specific_values
    assert_equal "debian", Settings.value
  end

  def test_settings_load_encrypted_values
    assert_equal "secret", Settings.password
  end

  def test_settings_load_specific_values_with_different_fact
    Object.send(:remove_const, :Settings)

    Caco::Facter.use_fake(fake_json_data) do
      Caco::SettingsLoader.(params: {
        keys_path: Caco.root.join("test", "fixtures", "keys"),
        data_path: Caco.root.join("test", "fixtures", "data")
      })
      assert_equal "darwin", Settings.value
    end

    # Teardown
    Object.send(:remove_const, :Settings)
    Caco::Facter.set_fake_data = Support.facter_data
    settings_loader
  end

  def fake_json_data
    {
      "kernel" => "Darwin",
      "os" => {
        "name" => "Darwin",
        "release" => {                                                                
          "full" => "18.7.0",                
          "major" => "18",                                                            
          "minor" => "7"              
        } 
      },
      "networking" => {
        "fqdn" => "machine"
      }
    }
  end
end
