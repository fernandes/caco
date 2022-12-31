require "test_helper"

class Caco::Resource::PackageTest < Minitest::Test
  def setup
  end

  class ProvidersTest < Minitest::Test
    class DebianTest < Minitest::Test
      def test_install_package
        returns = [
          [[false, 1, ""], ['dpkg -s foo']],
          [[true, 0, ""], ["apt-get install -y foo"]]
        ]

        Caco::Facter.use_fake(fake_json_data) do
          executer_stub(returns) do
            Caco.package "foo",
              guard: :present
          end
        end
      end

      def test_do_not_install_existing_package
        returns = [
          [[true, 0, ""], ['dpkg -s foo']],
          [[true, 0, stub_output_installed_package], ["dpkg-query -W -f='${Status} ${Version}\n' foo"]],
        ]

        Caco::Facter.use_fake(fake_json_data) do
          executer_stub(returns) do
            Caco.package "foo",
              guard: :present
          end
        end
      end

      def test_remove_installed_package
        returns = [
          [[true, 0, ""], ['dpkg -s foo']],
          [[true, 0, stub_output_installed_package], ["dpkg-query -W -f='${Status} ${Version}\n' foo"]],
          [[true, 0, ""], ["apt-get remove -y foo"]]
        ]

        Caco::Facter.use_fake(fake_json_data) do
          executer_stub(returns) do
            Caco.package "foo",
              guard: :absent
          end
        end
      end

      def test_do_not_remove_not_installed_package
        returns = [
          [[false, 1, ""], ['dpkg -s foo']],
          # [[false, 1, stub_output_never_installed_package], ["dpkg-query -W -f='${Status} ${Version}\n' foo"]],

        ]

        Caco::Facter.use_fake(fake_json_data) do
          executer_stub(returns) do
            Caco.package "foo",
              guard: :absent
          end
        end
      end

      def stub_output_installed_package
        <<~EOF
        install ok installed 11.6-1.pgdg90+1
        EOF
      end

      def stub_output_never_installed_package
        <<~EOF
        dpkg-query: no packages found matching foo
        EOF
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
      def test_install_package
        returns = [
          [[false, 1, ""], ['brew info foo']],
          [[true, 0, ""], ["brew install foo"]]
        ]

        Caco::Facter.use_fake(fake_json_data) do
          executer_stub(returns) do
            Caco.package "foo",
              guard: :present
          end
        end
      end

      def test_do_not_install_existing_package
        returns = [
          [[true, 0, ""], ['brew info foo']],
        ]

        Caco::Facter.use_fake(fake_json_data) do
          executer_stub(returns) do
            Caco.package "foo",
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
  
