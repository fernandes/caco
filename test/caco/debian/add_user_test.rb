require "test_helper"

class Caco::Debian::AddUserTest < Minitest::Test
  def setup
    clean_tmp_path
    file "/etc/passwd", content: passwd_content
  end

  def test_add_new_user
    returns = [
      [[true, 0, ""], ["adduser --disabled-password --gecos '' --quiet --force-badname foo"]],
    ]

    executer_stub(returns) do
      params = { user: "foo" }
      result = described_class.(params)
      assert result.success?
      assert result[:created]
    end
  end

  def test_add_existing_user
    returns = [
    ]

    executer_stub(returns) do
      params = { user: "user" }
      result = described_class.(params)
      assert result.success?
      refute result[:created]
    end
  end

  def passwd_content
    <<~EOF
    nobody:*:-2:-2:Unprivileged User:/var/empty:/usr/bin/false              
    root:*:0:0:System Administrator:/var/root:/bin/sh
    user:*:1000:1000:Celso Fernandes:/home/user:/bin/bash
    EOF
  end
end
