require "test_helper"

class Caco::Debian::AptUpdateTest < Minitest::Test
  def setup
    Caco::Debian.apt_updated = false
  end

  def test_update_on_first_time
    @commander = Minitest::Mock.new
    @commander.expect :call, [true, 0, ""], ['apt-get update']

    Caco::Executer.stub :execute, ->(command){ @commander.call(command) } do
      result = described_class.(params: {})
      assert result.success?
      assert result[:apt_needs_update]
      assert result[:apt_updated]
      assert Caco::Debian.apt_updated
    end

    @commander.verify
  end

  def test_bypass_when_updated
    Caco::Debian.apt_updated = true

    @commander = Minitest::Mock.new

    Caco::Executer.stub :execute, ->(command){ @commander.call(command) } do
      result = described_class.(params: {})
      assert result.success?
      refute result[:apt_needs_update]
      refute result[:apt_updated]
      assert Caco::Debian.apt_updated
    end

    @commander.verify
  end

  def test_force_when_specified
    Caco::Debian.apt_updated = true

    @commander = Minitest::Mock.new
    @commander.expect :call, [true, 0, ""], ['apt-get update']

    Caco::Executer.stub :execute, ->(command){ @commander.call(command) } do
      result = described_class.(params: {force: true})
      assert result.success?
      assert result[:apt_needs_update]
      assert result[:apt_updated]
      assert Caco::Debian.apt_updated
    end

    @commander.verify
  end

  def test_notify_apt_failed
    @commander = Minitest::Mock.new
    @commander.expect :call, [false, 1, ""], ['apt-get update']

    Caco::Executer.stub :execute, ->(command){ @commander.call(command) } do
      result = described_class.(params: {force: true})
      assert result.failure?
      assert result[:apt_needs_update]
      refute result[:apt_updated]
      refute Caco::Debian.apt_updated
    end

    @commander.verify
  end
end
