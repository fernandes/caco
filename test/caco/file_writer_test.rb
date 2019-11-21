require "test_helper"

class Caco::FileWriterTest < Minitest::Test
  def setup
    Caco.config.write_files = true
    FakeFS.activate!
    FileUtils.mkdir_p("/tmp")
    File.unlink("/tmp/file") if File.exist?("/tmp/file")
  end

  def teardown
    Caco.config.write_files = false
    FakeFS.deactivate!
  end

  def test_write_new_file
    result = described_class.(params: {path: "/tmp/file", content: output_data})
    assert result.success?
    assert result[:file_created]
    assert result[:file_changed]
    assert_equal File.read("/tmp/file"), output_data
  end

  def test_do_not_change_existing_file_with_same_content
    File.open("/tmp/file", File::RDWR|File::CREAT, 0644) do |f|
      f.write(output_data)
    end
    result = described_class.(params: {path: "/tmp/file", content: output_data})
    assert result.success?
    refute result[:file_created]
    refute result[:file_changed]
    assert_equal File.read("/tmp/file"), output_data
  end

  def test_change_existing_file_with_different_content
    File.open("/tmp/file", File::RDWR|File::CREAT, 0644) do |f|
      f.write("foo")
    end
    result = described_class.(params: {path: "/tmp/file", content: output_data})
    assert result.success?
    refute result[:file_created]
    assert result[:file_changed]
    assert_equal File.read("/tmp/file"), output_data
  end

  def test_create_directory_for_path
    result = described_class.(params: {path: "/tmp/path/to/file", content: output_data})
    assert result.success?
    assert result[:file_created]
    assert result[:file_changed]
    assert_equal File.read("/tmp/path/to/file"), output_data
  end

  def output_data
    <<~EOF
    Hello World
    New Line
    EOF
  end
end
