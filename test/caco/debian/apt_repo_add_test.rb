require "test_helper"

class Caco::Debian::AptRepoAddTest < Minitest::Test
  def setup
    Caco.config.write_files = false
  end

  def test_add_default_repo
    result = described_class.(
      params: {
        name: "pgdg", url: "http://apt.postgresql.org/pub/repos/apt/",
        release: "stretch-pgdg", component: "main"
      }
    )
    assert result.success?
    assert result[:repo_created]
    assert result[:repo_changed]
    assert_equal result[:content], "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main"
  end
end
