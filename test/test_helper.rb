APP_PATH = File.expand_path('../', __dir__)
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "caco"
Caco.root = Pathname.new(APP_PATH)

require 'pry'

require 'minitest/autorun'
require 'minitest/reporters'
require 'trailblazer/developer'
require 'fakefs/safe'
require 'webmock/minitest'

TMP_PATH = Caco.root.join("tmp").to_s
Dir.mkdir TMP_PATH unless File.exist? TMP_PATH

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

reporter_options = { color: true, slow_count: 5 }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]
Dev = Trailblazer::Developer

Caco::Facter.set_fake_data = Support.facter_data

Caco.configure do |config|
  config.write_files = false
end

class Minitest::Test
  def described_class
    self.class.to_s.gsub(/Test$/, '').constantize
  end

  def settings_loader
    Caco::SettingsLoader.(params: {
      keys_path: Caco.root.join("test", "fixtures", "keys"),
      data_path: Caco.root.join("test", "fixtures", "data")
    })
  end

  def executer_stub(returns)
    @commander = Minitest::Mock.new
    returns.each do |ret|
      @commander.expect :call, ret[0], ret[1]
    end

    Caco::Executer.stub :execute, ->(command){ @commander.call(command) } do
      yield
    end

    @commander.verify
  end
end

Caco::SettingsLoader.(params: {
  keys_path: Caco.root.join("test", "fixtures", "keys"),
  data_path: Caco.root.join("test", "fixtures", "data")
})

class String
  def constantize
    Kernel.const_get(self)
  end
end
