require "test_helper"

class Caco::DownloaderTest < Minitest::Test
  def setup
    clean_tmp_path
  end

  def test_download_a_file
    downloader_stub_request(stub_output)
    tempfile = Tempfile.new('downloader')
    path = tempfile.path
    tempfile.unlink

    result = described_class.(url: "http://example.com/file", dest: path)
    assert result.success?

    assert_equal stub_output, File.read(path)
    File.unlink(path) if File.exist?(path)
  end

  def test_stub_download_a_file
    downloader_stub_request("")
    tempfile = Tempfile.new('downloader')
    tempfile.write("stubbed")
    tempfile.rewind
    path = "#{Caco.config.write_files_root}/stubbed"

    result = described_class.(url: "http://example.com/file", dest: path, stubbed_file: tempfile.path)
    assert result.success?

    assert_equal "stubbed", File.read(path)
    tempfile.unlink
  end

  def test_using_fakefs_and_stubbed_file
    FakeFS do
      fakefs_clone
      FileUtils.mkdir_p("/tmp")

      tempfile = Tempfile.new('downloader')
      tempfile.write("stubbed: test_using_fakefs_and_stubbed_file")
      tempfile.rewind
      path = "#{Caco.config.write_files_root}/stubbed"

      result = described_class.(url: "http://example.com/file", dest: path, stubbed_file: tempfile.path)
      assert result.success?

      assert_equal "stubbed: test_using_fakefs_and_stubbed_file", File.read(path)
      File.unlink(path) if File.exist?(path)
    end
  end

  def stub_output
    <<~EOF
    Hello World
    EOF
  end
end
