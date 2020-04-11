require "test_helper"

class Caco::Rbenv::InstallVersionTest < Minitest::Test
  def test_install_new_version
    returns = []
    returns << [[false, 1, ""], [". /etc/profile && /opt/rbenv/bin/rbenv versions|egrep --color \"^..2.5.3( |$)\""]]
    returns << [[true, 0, ""], [". /etc/profile && /opt/rbenv/bin/rbenv install 2.5.3"]]

    executer_stub(returns) do
      result = described_class.(params: {version: '2.5.3'})
      assert result.success?
    end
  end

  def test_install_existing_version
    returns = []
    returns << [[true, 0, ""], [". /etc/profile && /opt/rbenv/bin/rbenv versions|egrep --color \"^..2.5.3( |$)\""]]

    executer_stub(returns) do
      result = described_class.(params: {version: '2.5.3'})
      assert result.success?
    end
  end
end
