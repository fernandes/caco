require "test_helper"

class Caco::Resource::ServiceTest < Minitest::Test
  def setup
  end

  class ProvidersTest < Minitest::Test
    class DebianTest < Minitest::Test
      def test_enable_disabled_service
        returns = [
          [[false, 1, "disabled"], ['systemctl is-enabled foo']],
          [[true, 0, ""], ["systemctl enable foo"]]
        ]

        Caco::Facter.use_fake(fake_json_data) do
          executer_stub(returns) do
            Caco.service "foo",
              guard: :present
          end
        end
      end

      def test_do_not_enable_enabled_service
        returns = [
          [[true, 0, "enabled"], ['systemctl is-enabled foo']],
        ]

        Caco::Facter.use_fake(fake_json_data) do
          executer_stub(returns) do
            Caco.service "foo",
              guard: :present
          end
        end
      end

      def test_disable_enabled_service
        returns = [
          [[true, 0, "enabled"], ['systemctl is-enabled foo']],
          [[true, 0, ""], ["systemctl disable foo"]]
        ]

        Caco::Facter.use_fake(fake_json_data) do
          executer_stub(returns) do
            Caco.service "foo",
              guard: :absent
          end
        end
      end

      def test_do_not_disable_disabled_service
        returns = [
          [[false, 1, "disabled"], ['systemctl is-enabled foo']],
        ]

        Caco::Facter.use_fake(fake_json_data) do
          executer_stub(returns) do
            Caco.service "foo",
              guard: :absent
          end
        end
      end

      def fake_json_data
        {
          "os" => {
            "name" => "Debian",
          }
        }
      end
    end

    class MacosTest < Minitest::Test
      def test_enable_disabled_service
        returns = [
          [[false, 1, ""], ['sudo launchctl list|egrep -iq foo']],
          [[true, 0, ""], ["sudo launchctl load foo"]]
        ]

        Caco::Facter.use_fake(fake_json_data) do
          executer_stub(returns) do
            Caco.service "foo",
              guard: :present
          end
        end
      end

      def test_do_not_enable_enabled_service
        returns = [
          [[true, 0, ""], ['sudo launchctl list|egrep -iq foo']],
        ]

        Caco::Facter.use_fake(fake_json_data) do
          executer_stub(returns) do
            Caco.service "foo",
              guard: :present
          end
        end
      end

      def fake_json_data
        {
          "os" => {
            "name" => "Darwin",
          }
        }
      end
    end
  end
end
  
