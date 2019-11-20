module Caco
  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Configuration.new
    yield(config)
  end

  class Configuration
    attr_accessor :root
    attr_accessor :eyaml_parser

    def initialize
      @root = 'donotreply@example.com'
    end
  end
end
