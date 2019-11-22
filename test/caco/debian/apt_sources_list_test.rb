require "test_helper"

class Caco::Debian::AptSourcesListTest < Minitest::Test
  def setup
    clean_tmp_path
  end

  def test_add_default_repo
    result = described_class.(
      params: {
      }
    )
    assert result.success?
    assert_equal default_output, result[:content]
    assert result[:sources_updated]
  end

  def default_output
    <<~EOF
    # File Managed, Dot Not Edit
    deb http://ftp.br.debian.org/debian stretch main
    deb-src http://ftp.br.debian.org/debian stretch main

    deb http://security.debian.org/debian-security stretch/updates main
    deb-src http://security.debian.org/debian-security stretch/updates main

    # stretch-updates, previously known as 'volatile'
    deb http://ftp.br.debian.org/debian stretch-updates main
    deb-src http://ftp.br.debian.org/debian stretch-updates main
    EOF
  end
end
