require "test_helper"

class Caco::FileWriterTest < Minitest::Test
  def setup
    FakeFS.activate!
    FileUtils.mkdir_p("/tmp")
    File.unlink("/tmp/file") if File.exist?("/tmp/file")
  end

  def teardown
    FakeFS.deactivate!
  end

  def test_write_new_file
    result = described_class.(params: {path: "/tmp/file", content: output_data})
    assert result.success?
    assert result[:file_changed]
    assert_equal File.read("/tmp/file"), output_data
  end

  def test_change_existing_file
    File.open("/tmp/file", File::RDWR|File::CREAT, 0644) do |f|
      f.write(output_data)
    end
    result = described_class.(params: {path: "/tmp/file", content: output_data})
    assert result.success?
    refute result[:file_changed]
    assert_equal File.read("/tmp/file"), output_data
  end

  def test_no_change_change_to_existing_file
    File.open("/tmp/file", File::RDWR|File::CREAT, 0644) do |f|
      f.write("foo")
    end
    result = described_class.(params: {path: "/tmp/file", content: output_data})
    assert result.success?
    assert result[:file_changed]
    assert_equal File.read("/tmp/file"), output_data
  end

  def output_data
    <<~EOF
    Hello World
    New Line
    EOF
  end
end
