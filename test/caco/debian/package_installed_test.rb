require "test_helper"

class Caco::Debian::PackageInstalledTest < Minitest::Test
  def test_dpkg_and_query_installed
    returns = [
      [[true, 0, ""], ['dpkg -s package']],
      [[true, 0, stub_output_installed_package], ["dpkg-query -W -f='${Status} ${Version}\n' package"]]
    ]

    executer_stub(returns) do
      result = described_class.(params: { package: "package" })
      assert result.success?
    end
  end

  def test_dpkg_not_installed
    returns = [
      [[false, 1, ""], ['dpkg -s package']],
    ]

    executer_stub(returns) do
      result = described_class.(params: { package: "package" })
      assert result.failure?
    end
  end

  def test_dpkg_query_deinstalled_package
    returns = [
      [[true, 0, ""], ['dpkg -s package']],
      [[true, 0, stub_output_deinstalled_package], ["dpkg-query -W -f='${Status} ${Version}\n' package"]]
    ]

    executer_stub(returns) do
      result = described_class.(params: { package: "package" })
      assert result.failure?
    end
  end

  def test_dpkg_query_never_installed_package
    returns = [
      [[true, 0, ""], ['dpkg -s package']],
      [[true, 0, stub_output_never_installed_package], ["dpkg-query -W -f='${Status} ${Version}\n' package"]]
    ]

    executer_stub(returns) do
      result = described_class.(params: { package: "package" })
      assert result.failure?
    end
  end

  def stub_output_deinstalled_package
    <<~EOF
    deinstall ok config-files 12.1-1.pgdg90+1
    EOF
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
