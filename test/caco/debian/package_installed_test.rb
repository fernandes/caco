require "test_helper"

class Caco::Debian::PackageInstalledTest < Minitest::Test
  def test_dpkg_installed_success_fooo
    described_class.stub :dpkg_installed?, true do
      described_class.stub :dpkg_query_installed?, true do
        assert described_class.(package: "package")
      end
    end

    described_class.stub :dpkg_installed?, true do
      described_class.stub :dpkg_query_installed?, false do
        refute described_class.(package: "package")
      end
    end

    described_class.stub :dpkg_installed?, false do
      described_class.stub :dpkg_query_installed?, true do
        refute described_class.(package: "package")
      end
    end

    described_class.stub :dpkg_installed?, false do
      described_class.stub :dpkg_query_installed?, false do
        refute described_class.(package: "package")
      end
    end
  end

  # dpkg_installed?
  def test_dpkg_installed_success
    @commander = Minitest::Mock.new
    @commander.expect :call, [true, 0, ""], ['dpkg -s package']

    Caco::Executer.stub :execute, ->(command){ @commander.call(command) } do
      assert described_class.dpkg_installed?(package: "package")
    end

    @commander.verify
  end

  def test_dpkg_installed_failure
    @commander = Minitest::Mock.new
    @commander.expect :call, [false, 1, ""], ['dpkg -s package']

    Caco::Executer.stub :execute, ->(command){ @commander.call(command) } do
      refute described_class.dpkg_installed?(package: "package")
    end

    @commander.verify
  end

  # dpkg_query_installed?
  def test_dpkg_query_installed_success
    @commander = Minitest::Mock.new
    @commander.expect :call, [true, 0, stub_output_installed_package], ["dpkg-query -W -f='${Status} ${Version}\n' package"]

    Caco::Executer.stub :execute, ->(command){ @commander.call(command) } do
      assert described_class.dpkg_query_installed?(package: "package")
    end

    @commander.verify
  end

  def test_dpkg_query_installed_failure_on_deinstall
    @commander = Minitest::Mock.new
    @commander.expect :call, [true, 0, stub_output_deinstalled_package], ["dpkg-query -W -f='${Status} ${Version}\n' package"]

    Caco::Executer.stub :execute, ->(command){ @commander.call(command) } do
      refute described_class.dpkg_query_installed?(package: "package")
    end

    @commander.verify
  end

  def test_dpkg_query_installed_failure_on_never_installed
    @commander = Minitest::Mock.new
    @commander.expect :call, [true, 0, stub_output_never_installed_package], ["dpkg-query -W -f='${Status} ${Version}\n' package"]

    Caco::Executer.stub :execute, ->(command){ @commander.call(command) } do
      refute described_class.dpkg_query_installed?(package: "package")
    end

    @commander.verify
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
