# Let warning enabled for application, but silence for gems
require "warning"
Gem.path.each do |path|
  Warning.ignore(//, path)
end

APP_PATH = File.expand_path("../", __dir__)
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
ENV["CACO_LOG_FILE"] = "#{APP_PATH}/test/tmp/caco.log"
require "caco"
Caco.root = Pathname.new(APP_PATH)

require "pry"

require "minitest/autorun"
require "minitest/reporters"
require "trailblazer/developer"
require "fakefs/safe"
require "webmock/minitest"

TMP_PATH = Caco.root.join("test", "tmp").to_s
FileUtils.rm_r(TMP_PATH, force: true) if File.exist?(TMP_PATH)
Dir.mkdir TMP_PATH unless File.exist? TMP_PATH

Caco.configure do |config|
  config.write_files_root = Caco.root.join(TMP_PATH)
  config.write_files = true
end

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }
reporter_options = {color: true, slow_count: 5}
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]
Dev = Trailblazer::Developer

Caco::Facter.set_fake_data = Support.facter_data

class Minitest::Test
  def described_class
    self.class.to_s.gsub(/Test$/, "").constantize
  end

  def settings_loader
    Caco::SettingsLoader.call(keys_path: Caco.root.join("test", "fixtures", "keys"),
      data_path: Caco.root.join("test", "fixtures", "data"))
  end

  def executer_stub(returns)
    @commander = Minitest::Mock.new
    returns.each do |ret|
      output = Caco::Resource::Execute::Output.new(
        success: ret[0][0],
        exit_status: ret[0][1],
        stdout: ret[0][2],
        stderr: ret[0][3]
      )
      @commander.expect :call, output, ret[1]
    end

    Caco::Resource::Execute.stub :execute, ->(command, cwd: "/tmp", stream_output: nil) { @commander.call(command) } do
      yield
    end

    @commander.verify
  end

  def clean_tmp_path
    FileUtils.rm_r(TMP_PATH, force: true) if File.exist?(TMP_PATH)
    Dir.mkdir TMP_PATH unless File.exist? TMP_PATH
  end

  def downloader_stub_request(body = "", url: "http://example.com/file")
    stub_request(:get, url).with(
      headers: {
        "Connection" => "close",
        "User-Agent" => "Down/5.4.2"
      }
    ).to_return(status: 200, body: body, headers: {})
  end

  def fakefs(&block)
    FakeFS do
      fakefs_clone

      yield
    end
  end

  def fakefs_clone
    FileUtils.mkdir_p("/tmp")
    FakeFS::FileSystem.clone(Caco.root.join("lib", "caco"))
    FakeFS::FileSystem.clone(Caco.root.join("test", "fixtures"))
  end

  def fixture_file(name)
    pathname = Caco.root.join("test", "fixtures", name)
    raise Caco::FixtureNotExist.new("Fixture file #{name} does not exist") unless File.exist?(pathname)
    pathname
  end
end

Caco::SettingsLoader.call(keys_path: Caco.root.join("test", "fixtures", "keys"),
  data_path: Caco.root.join("test", "fixtures", "data"))

# class String
#   def constantize
#     Kernel.const_get(self)
#   end
# end
