require "test_helper"

class Caco::RbenvTest < Minitest::Test
  def setup
    clean_tmp_path
    FileUtils.mkdir_p(TMP_PATH)
    Caco::Rbenv.root = "#{TMP_PATH}/opt/rbenv"
  end

  def teardown
    Caco::Rbenv.root = "/opt/rbenv"
  end

  class Install < Caco::RbenvTest
    # This test is like a remined if I need to run a sequence of commandss
    def test_install
      returns = stub_for_dependencies
      returns << [[true, 0, ""], ["git clone https://github.com/rbenv/rbenv.git #{TMP_PATH}/opt/rbenv"]]

      executer_stub(returns) do
        Caco::Rbenv.install
      end

      assert_equal File.read("#{TMP_PATH}/etc/profile.d/rbenv.sh"), profile_content
    end
  end

  class VersionInstalledTest < Caco::RbenvTest
    def test_for_new_one
      returns = [
        [[false, 1, ""], [rbenv_command("rbenv versions|egrep -q \"2.7.6\"")]]
      ]

      executer_stub(returns) do
        refute Caco::Rbenv.version_installed?("2.7.6")
      end
    end

    def test_for_existing_one
      returns = [
        [[true, 0, ""], [rbenv_command("rbenv versions|egrep -q \"2.7.5\"")]]
      ]

      executer_stub(returns) do
        assert Caco::Rbenv.version_installed?("2.7.5")
      end
    end
  end

  class InstallVersion < Caco::RbenvTest
    def test_install_version
      returns = [
        [[false, 1, ""], [rbenv_command("rbenv versions|egrep -q \"2.7.5\"")]],
        [[true, 0, ""], [rbenv_command("rbenv install 2.7.5")]]
      ]

      executer_stub(returns) do
        Caco::Rbenv.install_version("2.7.5")
      end
    end
  end

  class GlobalVersion < Caco::RbenvTest
    def test_global_version
      returns = [
        [[true, 0, "2.7.5\n"], [rbenv_command("rbenv global")]]
      ]

      executer_stub(returns) do
        assert_equal "2.7.5", Caco::Rbenv.global_version
      end
    end

    def test_set_global_version
      returns = [
        [[true, 0, "2.7.5\n"], [rbenv_command("rbenv global")]],
        [[true, 0, ""], [rbenv_command("rbenv global 2.7.6")]]
      ]

      executer_stub(returns) do
        assert Caco::Rbenv.global_version = "2.7.6"
      end
    end

    def test_set_global_version_idempotent
      returns = [
        [[true, 0, "2.7.6\n"], [rbenv_command("rbenv global")]]
      ]

      executer_stub(returns) do
        assert Caco::Rbenv.global_version = "2.7.6"
      end
    end
  end

  class RbenvCommandTest < Caco::RbenvTest
    def test_run_command
      command = <<~COMMAND
        export PATH="#{Caco::Rbenv.install_to}/bin:${PATH}" ;
        export RBENV_ROOT="#{Caco::Rbenv.install_to}" ;
        eval "$(rbenv init -)";
        rbenv foo
      COMMAND

      returns = [
        [[true, 0, "2.7.5\n"], [command]]
      ]

      executer_stub(returns) do
        Caco::Rbenv.rbenv_command("foo", command: "rbenv foo")
      end
    end
  end

  class InstallRubyBuildTest < Caco::RbenvTest
    def test_install_ruby_build
      returns = [
        [[true, 0, ""], ["git clone https://github.com/rbenv/ruby-build.git #{Caco::Rbenv.install_to}/plugins/ruby-build"]]
      ]

      File.stub :exist?, false do
        executer_stub(returns) do
          Caco::Rbenv.install_ruby_build
        end
      end
    end
  end

  class InstallRbenvEachTest < Caco::RbenvTest
    def test_install_rbenv_each
      returns = [
        [[true, 0, ""], ["git clone https://github.com/rbenv/rbenv-each.git #{Caco::Rbenv.install_to}/plugins/rbenv-each"]]
      ]

      File.stub :exist?, false do
        executer_stub(returns) do
          Caco::Rbenv.install_rbenv_each
        end
      end
    end
  end

  def stub_for_dependencies
    returns = []
    %w[
      git autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev
      libffi-dev libgdbm3 libgdbm-dev
    ].each do |pkg|
      returns << [[false, 1, ""], ["dpkg -s #{pkg}"]]
      returns << [[true, 0, ""], ["apt-get install -y #{pkg}"]]
    end
    returns
  end

  def rbenv_command(command)
    <<~COMMAND
      export PATH="#{Caco::Rbenv.install_to}/bin:${PATH}" ;
      export RBENV_ROOT="#{Caco::Rbenv.install_to}" ;
      eval "$(rbenv init -)";
      #{command}
    COMMAND
  end

  def profile_content
    <<~CONTENT
      export PATH="/opt/rbenv/bin:$PATH"
      export RBENV_ROOT="/opt/rbenv"
      eval "$(rbenv init -)"
    CONTENT
  end
end
