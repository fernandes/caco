require "test_helper"

class Caco::Sudo::SudoersAddTest < Minitest::Test
  def setup
    clean_tmp_path
  end

  def test_add_sudoers_file
    params = { identifier: "postgres", content: sudoers_content }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    assert result.success?
    assert result[:created]
    assert result[:changed]

    # Test File Config
    result = Caco::FileReader.(path: "/etc/sudoers.d/postgres")
    assert_equal sudoers_content, result[:output]
  end

  def test_change_sudoers_file
    params = { identifier: "postgres", content: sudoers_content }
    described_class.(params)

    params = { identifier: "postgres", content: "foo" }
    result = described_class.(params)
    assert result.success?
    refute result[:created]
    assert result[:changed]

    # Test File Config
    result = Caco::FileReader.(path: "/etc/sudoers.d/postgres")
    assert_equal "foo", result[:output]
  end

  def sudoers_content
    <<~EOF
    postgres ALL = NOPASSWD: /usr/bin/pg_ctlcluster 12 main stop, \
      /usr/bin/pg_ctlcluster 12 main start,
    EOF
  end
end
