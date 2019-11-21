require "test_helper"

class Caco::DownloaderTest < Minitest::Test
  def setup
    Caco.config.write_files = true
  end

  def teardown
    Caco.config.write_files = false
  end

  def test_download_a_file
    downloader_stub_request(stub_output)
    tempfile = Tempfile.new('downloader')
    path = tempfile.path
    tempfile.unlink

    result = described_class.(params: {url: "http://example.com/file", dest: path})
    assert result.success?

    assert_equal stub_output, File.read(path)
    File.unlink(path) if File.exist?(path)
  end

  def stub_output
    <<~EOF
    Hello World
    EOF
  end

  def downloader_stub_request(body = "")
    stub_request(:get, "http://example.com/file").with(
      headers: {
        'Connection'=>'close',
        'User-Agent'=>'Down/5.0.0'
      }).to_return(status: 200, body: stub_output, headers: {})
  end
end
