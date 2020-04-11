
require "test_helper"

class Caco::UnpackerTest < Minitest::Test
  UNPACK_PATH = Pathname.new(TMP_PATH).join("unpack")
  FIXTURES_PATH = Caco.root.join("test", "fixtures")

  def setup
    FileUtils.rm_rf(UNPACK_PATH) if File.exist?(UNPACK_PATH)
  end

  def teardown
    FileUtils.rm_rf(UNPACK_PATH) if File.exist?(UNPACK_PATH)
  end

  def test_unpack_tar_file
    params = { pack: FIXTURES_PATH.join("tar_file"), dest: UNPACK_PATH }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    assert result.success?
    assert File.exist?(FIXTURES_PATH.join("tar_file"))
    assert_equal "hello tar\n", File.read(UNPACK_PATH.join("tar_content", "file.txt"))
  end

  def test_unpack_tar_gz_file
    params = { pack: FIXTURES_PATH.join("tar_gz_file"), dest: UNPACK_PATH }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    assert result.success?
    assert File.exist?(FIXTURES_PATH.join("tar_gz_file"))
    assert_equal "hello tar.gz\n", File.read(UNPACK_PATH.join("tar_content", "file.txt"))
  end

  def test_unpack_tar_bz2_file
    params = { pack: FIXTURES_PATH.join("tar_bz2_file"), dest: UNPACK_PATH }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    assert result.success?
    assert File.exist?(FIXTURES_PATH.join("tar_bz2_file"))
    assert_equal "hello tar.bz2\n", File.read(UNPACK_PATH.join("tar_content", "file.txt"))
  end

  def test_unpack_gz_file
    params = { pack: FIXTURES_PATH.join("gzip_file"), dest: UNPACK_PATH }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    assert result.success?
    assert File.exist?(FIXTURES_PATH.join("gzip_file"))
    assert_equal "hello from gzip\n", File.read(UNPACK_PATH.join("gzip_file"))
  end

  def test_failure_for_unknown_format_file
    params = { pack: FIXTURES_PATH.join("unknown_format_file"), dest: UNPACK_PATH }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    assert result.failure?
    assert_equal "application/octet-stream", result[:unknown_file_mime]
    assert_equal "unknown_format", result[:failure_reason]
  end
end
