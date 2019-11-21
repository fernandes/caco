require "test_helper"

class Caco::Debian::Cell::SourcesListTest < Minitest::Test
  def setup
    settings_loader
  end

  def test_output
    output = described_class.().to_s
    assert_equal output, default_output
  end

  def test_output_with_mirror_url
    output = described_class.(mirror_url: "http://foo.com/debian").to_s
    assert_equal output, mirror_url_output
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

  def mirror_url_output
    <<~EOF
    # File Managed, Dot Not Edit
    deb http://foo.com/debian stretch main
    deb-src http://foo.com/debian stretch main

    deb http://security.debian.org/debian-security stretch/updates main
    deb-src http://security.debian.org/debian-security stretch/updates main

    # stretch-updates, previously known as 'volatile'
    deb http://foo.com/debian stretch-updates main
    deb-src http://foo.com/debian stretch-updates main
    EOF
  end
end
