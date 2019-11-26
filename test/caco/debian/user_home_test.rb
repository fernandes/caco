require "test_helper"

class Caco::Debian::UserHomeTest < Minitest::Test
  def setup
    clean_tmp_path
    Caco::FileWriter.(params: { path: "/etc/passwd", content: passwd_content})
  end

  def test_find_home_for_root
    params = { params: { user: "root" } }
    result = described_class.(params)

    assert result.success?
    assert_equal "/var/root", result[:user_home]
  end

  def test_find_home_for_user
    params = { params: { user: "user" } }
    result = described_class.(params)

    assert result.success?
    assert_equal "/home/user", result[:user_home]
  end

  def test_fail_for_non_existing_user
    params = { params: { user: "foo" } }
    result = described_class.(params)

    assert result.failure?
    assert_nil result[:user_home]
  end

  def passwd_content
    <<~EOF
    nobody:*:-2:-2:Unprivileged User:/var/empty:/usr/bin/false              
    root:*:0:0:System Administrator:/var/root:/bin/sh
    user:*:1000:1000:Celso Fernandes:/home/user:/bin/bash
    EOF
  end
end
