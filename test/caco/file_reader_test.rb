require "test_helper"

class Caco::FileReaderTest < Minitest::Test
  FILE_READER_PATH = "#{TMP_PATH}/file_reader"

  def setup
    clean_tmp_path
    FileUtils.mkdir_p(FILE_READER_PATH)
  end

  def test_read_file
    File.open("#{TMP_PATH}/file_reader/file", File::RDWR|File::CREAT, 0644) do |f|
      f.write(output_data)
    end

    result = described_class.(path: "/file_reader/file")
    assert result.success?
    assert_equal output_data, result[:output]
  end

  def test_read_unknown_file
    result = described_class.(path: "/file_reader/unknown_file")
    assert result.failure?
    refute result[:output]
  end

  def output_data
    <<~EOF
    Hello World
    New Line
    EOF
  end
end
