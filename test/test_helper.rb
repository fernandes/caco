$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "caco"
require 'pry'

require 'minitest/autorun'
require 'minitest/reporters'
require 'trailblazer/developer'
require 'fakefs/safe'

ROOT_PATH = File.expand_path("../../", __FILE__)
TMP_PATH = File.join(ROOT_PATH, "tmp")

Dir.mkdir TMP_PATH unless File.exist? TMP_PATH

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }

reporter_options = { color: true, slow_count: 5 }
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]
Dev = Trailblazer::Developer

Caco::Facter.set_fake_data = Support.facter_data

class Minitest::Test
  def described_class
    self.class.to_s.gsub(/Test$/, '').constantize
  end
end


class String
  def constantize
    Kernel.const_get(self)
  end
end
