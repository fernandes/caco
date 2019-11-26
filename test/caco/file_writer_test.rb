require "test_helper"

class Caco::FileWriterTest < Minitest::Test
  FILE_WRITER_PATH = "#{TMP_PATH}/file_writer"

  def setup
    clean_tmp_path
    FileUtils.mkdir_p(FILE_WRITER_PATH)
  end

  def test_write_new_file
    result = described_class.(params: {path: "/file_writer/file", content: output_data})
    assert result.success?
    assert result[:file_created]
    assert result[:file_changed]
    assert_equal File.read("#{TMP_PATH}/file_writer/file"), output_data
  end

  def test_do_not_change_existing_file_with_same_content
    File.open("#{TMP_PATH}/file_writer/file", File::RDWR|File::CREAT, 0644) do |f|
      f.write(output_data)
    end
    result = described_class.(params: {path: "/file_writer/file", content: output_data})
    assert result.success?
    refute result[:file_created]
    refute result[:file_changed]
    assert_equal File.read("#{TMP_PATH}/file_writer/file"), output_data
  end

  def test_change_existing_file_with_different_content
    File.open("#{TMP_PATH}/file_writer/file", File::RDWR|File::CREAT, 0644) do |f|
      f.write("foo")
    end
    result = described_class.(params: {path: "/file_writer/file", content: output_data})
    assert result.success?
    refute result[:file_created]
    assert result[:file_changed]
    assert_equal File.read("#{TMP_PATH}/file_writer/file"), output_data
  end

  def test_create_directory_for_path
    result = described_class.(params: {path: "/file_writer/path/to/file", content: output_data})
    assert result.success?
    assert result[:file_created]
    assert result[:file_changed]
    assert_equal File.read("#{TMP_PATH}/file_writer/path/to/file"), output_data
  end

  def test_when_prefix_with_tmp_path_do_not_duplicate_it
    result = described_class.(params: {path: "#{TMP_PATH}/file_writer/path/to/file", content: output_data})
    assert result.success?
    assert result[:file_created]
    assert result[:file_changed]
    assert_equal File.read("#{TMP_PATH}/file_writer/path/to/file"), output_data
  end

  def output_data
    <<~EOF
    Hello World
    New Line
    EOF
  end
end
