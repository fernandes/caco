require "test_helper"

class Caco::Rbenv::InstallTest < Minitest::Test
  def setup
    clean_tmp_path
  end

  def test_install_package
    returns = build_returns
    returns << [[true, 0, ""], ["git clone https://github.com/rbenv/rbenv.git /opt/rbenv"]]
    returns << [[true, 0, ""], ["[ ! -f /opt/rbenv/libexec/rbenv-realpath.dylib ] && cd /opt/rbenv && src/configure && make -C src"]]

    Caco::Rbenv::Install.stub :repo_exist?, false do
      executer_stub(returns) do
        # Dev.wtf?(described_class, {})
        result = described_class.()
        assert result.success?
        
        result = Caco::FileReader.(params: {path: "/etc/profile.d/rbenv.sh"})
        assert_equal profile_content, result[:output]
      end
    end
  end

  def test_bypass_git_clone_when_exist
    returns = build_returns
    returns << [[false, 1, ""], ["[ ! -f /opt/rbenv/libexec/rbenv-realpath.dylib ] && cd /opt/rbenv && src/configure && make -C src"]]

    Caco::Rbenv::Install.stub :repo_exist?, true do
      executer_stub(returns) do
        # Dev.wtf?(described_class, {})
        result = described_class.()
        assert result.success?
        
        result = Caco::FileReader.(params: {path: "/etc/profile.d/rbenv.sh"})
        assert_equal profile_content, result[:output]
      end
    end
  end

  def profile_content
    <<~EOF
    export PATH="/opt/rbenv/bin:$PATH"
    export RBENV_ROOT="/opt/rbenv"
    eval "$(rbenv init -)"
    EOF
  end

  def build_returns
    returns = []
    packages = %w(git autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev)
    packages.each do |package|
      returns << [[false, 1, ""], ["dpkg -s #{package}"]]
      returns << [[true, 0, ""], ["apt-get install -y #{package}"]]
    end
    returns
  end
end
