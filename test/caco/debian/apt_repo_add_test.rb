require "test_helper"

class Caco::Debian::AptRepoAddTest < Minitest::Test
  def setup
    clean_tmp_path
  end

  def test_add_repo
    result = described_class.(
      name: "pgdg", url: "http://apt.postgresql.org/pub/repos/apt/",
      release: "stretch-pgdg", component: "main"
    )
    assert result.success?
    assert result[:repo_created]
    assert result[:repo_changed]
    assert_equal result[:content], "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main"
  end

  def test_change_repo_on_existing_file
    Caco::FileWriter.(path: "/etc/apt/sources.list.d/pgdg.list", content: "foo")

    params = {
      name: "pgdg", url: "http://apt.postgresql.org/pub/repos/apt/",
      release: "stretch-pgdg", component: "main"
    }

    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    assert result.success?
    refute result[:repo_created]
    assert result[:repo_changed]
    assert_equal result[:content], "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main"
  end
end
