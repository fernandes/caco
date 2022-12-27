require "test_helper"

class Caco::Resource::FileTest < Minitest::Test
  FILE_WRITER_PATH = "#{TMP_PATH}/file_writer"

  def setup
    clean_tmp_path
    FileUtils.mkdir_p(FILE_WRITER_PATH)
  end

  def test_write_new_file
    result = file "/file_writer/file",
      content: output_data
  
    assert result[:created]
    assert result[:changed]
    assert_equal File.read("#{TMP_PATH}/file_writer/file"), output_data
  end

  def test_do_not_change_existing_file_with_same_content
    File.open("#{TMP_PATH}/file_writer/file", File::RDWR|File::CREAT, 0644) do |f|
      f.write(output_data)
    end

    result = file "/file_writer/file", content: output_data

    refute result[:created]
    refute result[:changed]
    assert_equal File.read("#{TMP_PATH}/file_writer/file"), output_data
  end


  def test_change_existing_file_with_different_content
    File.open("#{TMP_PATH}/file_writer/file", File::RDWR|File::CREAT, 0644) do |f|
      f.write("foo")
    end
    result = file "/file_writer/file", content: output_data

    # refute result[:created]
    assert result[:changed]
    # assert_equal File.read("#{TMP_PATH}/file_writer/file"), output_data
  end

  def test_create_directory_for_path
    result = file "/file_writer/path/to/file", content: output_data
    assert result[:created]
    # assert result[:changed]
    # assert_equal File.read("#{TMP_PATH}/file_writer/path/to/file"), output_data
  end

  def test_when_prefix_with_tmp_path_do_not_duplicate_it
    result = file "#{TMP_PATH}/file_writer/path/to/file", content: output_data
    assert result[:created]
    # assert result[:changed]
    # assert_equal File.read("#{TMP_PATH}/file_writer/path/to/file"), output_data
  end

  def output_data
    <<~EOF
    Hello World
    New Line
    EOF
  end

  def test_foo
    assert true
  end
end


 
  
