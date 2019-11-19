require "test_helper"

class Caco::Debian::PackageInstallTest < Minitest::Test
  def test_install_not_installed_package
    Caco::Debian::PackageInstalled.stub :call, false do
      Caco::Executer.stub :call, true do
        result = described_class.(params: {package: "foo"})
        assert result.success?
        assert result[:package_needs_install]
        assert result[:package_installed]
      end
    end
  end

  def test_do_not_install_installed_package
    Caco::Debian::PackageInstalled.stub :call, true do
      result = described_class.(params: {package: "foo"})
      assert result.success?
      refute result[:package_needs_install]
      refute result[:package_installed]
    end
  end

  def test_raise_error_on_missing_package
    err = assert_raises described_class::PackageNameError do
      described_class.(params: {package: ""})
    end
    assert_match /Provide a package name/, err.message
  end
end
