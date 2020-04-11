require "test_helper"

class Caco::FileLinkTest < Minitest::Test
  LINK_PATH = Pathname.new(TMP_PATH).join("file_link_test")

  def setup
    FileUtils.mkdir_p(LINK_PATH) unless File.exist?(LINK_PATH)
    @target = Pathname.new(LINK_PATH).join("target.txt")
    @link = Pathname.new(LINK_PATH).join("link.txt")
    @target_dummy = Pathname.new(LINK_PATH).join("target.dummy.txt")
    @link_dummy = Pathname.new(LINK_PATH).join("link.dummy.txt")
    File.write(@target, 'Hello World') unless File.exist?(@target)
    File.write(@target_dummy, 'Hello World Dummy') unless File.exist?(@target)
  end

  def teardown
    FileUtils.rm_rf(LINK_PATH) if File.exist?(LINK_PATH)
  end

  def test_create_unexisting_link
    params = { target: @target, link: @link }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    assert result.success?
    refute result[:link_exist]
    refute result[:link_same_target]
    refute result[:force]
    assert result[:link_created]
  end

  def test_change_target_existing_link
    FileUtils.ln_s @target_dummy, @link

    params = { target: @target, link: @link }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    assert result.success?
    assert result[:link_exist]
    refute result[:link_same_target]
    assert result[:force]
    assert result[:link_created]
  end

  def test_bypass_target_existing_link
    FileUtils.ln_s @target, @link

    params = { target: @target, link: @link }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    assert result.success?
    assert result[:link_exist]
    assert result[:link_same_target]
    refute result[:force]
    refute result[:link_created]
  end

  def test_create_link_missing_target
    params = { target: @target_dummy, link: @link }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    assert result.success?
    refute result[:link_exist]
    refute result[:link_same_target]
    refute result[:force]
    assert result[:link_created]
  end

  def test_create_link_missing_target
    params = { target: @target_dummy, link: @link, ensure_target: true }
    # Dev.wtf?(described_class, params)
    result = described_class.(params)
    refute result.success?
    refute result[:link_exist]
    refute result[:target_exist]
    refute result[:link_same_target]
    refute result[:force]
    refute result[:link_created]
  end
end
