require "test_helper"

class Caco::Ssh::AuthorizedKeysAddTest < Minitest::Test
  def setup
    clean_tmp_path
    Caco::FileWriter.(params: { path: "/etc/passwd", content: passwd_content})
  end

  def test_add_new_key
    params = { params: { user: "fernandes", identifier: "fernandes@mail.com", key: "ssh-rsa AAAAB3NzaC1==" } }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    assert result.success?
    assert result[:created]
    assert result[:changed]

    # Test File Config
    result = Caco::FileReader.(params: { path: "/home/fernandes/.ssh/authorized_keys" })
    assert_equal "ssh-rsa AAAAB3NzaC1== fernandes@mail.com\n", result[:output]
  end

  def test_add_duplicate_key
    params = { params: { user: "fernandes", identifier: "fernandes@mail.com", key: "ssh-rsa AAAAB3NzaC1==" } }
    # add for the first time
    described_class.(params)

    # then check for duplicated entry
    result = described_class.(params)
    assert result.success?
    refute result[:created]
    refute result[:changed]

    # Test File Config
    result = Caco::FileReader.(params: { path: "/home/fernandes/.ssh/authorized_keys" })
    assert_equal "ssh-rsa AAAAB3NzaC1== fernandes@mail.com\n", result[:output]
  end

  def test_change_identifier_key
    params = { params: { user: "fernandes", identifier: "fernandes@mail.com", key: "ssh-rsa AAAAB3NzaC1==" } }
    # add for the first time
    described_class.(params)

    # then check for duplicated entry
    params = { params: { user: "fernandes", identifier: "fernandes@mail.com", key: "ssh-rsa AAAAB3NzaC2==" } }
    result = described_class.(params)
    assert result.success?
    refute result[:created]
    assert result[:changed]

    # Test File Config
    result = Caco::FileReader.(params: { path: "/home/fernandes/.ssh/authorized_keys" })
    assert_equal "ssh-rsa AAAAB3NzaC2== fernandes@mail.com\n", result[:output]
  end

  def passwd_content
    <<~EOF
    nobody:*:-2:-2:Unprivileged User:/var/empty:/usr/bin/false              
    root:*:0:0:System Administrator:/var/root:/bin/sh
    fernandes:*:1000:1000:Celso Fernandes:/home/fernandes:/bin/bash
    EOF
  end
end
