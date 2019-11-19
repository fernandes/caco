require "test_helper"

class Caco::Debian::AptRepoAddTest < Minitest::Test
  def setup
    FakeFS.activate!
    FileUtils.mkdir_p("/etc/apt/sources.list.d")
  end

  def teardown
    FakeFS.deactivate!
  end

  def test_add_default_repo
    result = described_class.(
      params: {
        name: "pgdg", url: "http://apt.postgresql.org/pub/repos/apt/",
        release: "stretch-pgdg", component: "main"
      }
    )
    assert result.success?
    assert result[:repo_changed]

    repo_content = File.read("/etc/apt/sources.list.d/pgdg.list")
    assert_equal repo_content, "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main"
  end
end
