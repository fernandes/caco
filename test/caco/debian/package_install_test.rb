require "test_helper"

class Caco::Debian::PackageInstallTest < Minitest::Test
  def test_install_not_installed_package
    returns = [
      [[false, 1, ""], ['dpkg -s foo']],
      [[true, 0, ""], ["apt-get install -y foo"]]
    ]

    executer_stub(returns) do
      result = described_class.(params: {package: "foo"})
      assert result.success?
      refute result[:already_installed]
    end
  end

  def test_do_not_install_installed_package
    returns = [
      [[true, 0, ""], ['dpkg -s foo']],
      [[true, 0, stub_output_installed_package], ["dpkg-query -W -f='${Status} ${Version}\n' foo"]],
    ]

    executer_stub(returns) do
      result = described_class.(params: {package: "foo"})
      assert result.success?
      assert result[:already_installed]
    end
  end

  def stub_output_installed_package
    <<~EOF
    install ok installed 11.6-1.pgdg90+1
    EOF
  end

  def stub_output_never_installed_package
    <<~EOF
    dpkg-query: no packages found matching asiuehu
    EOF
  end
end
