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

    def initialize
      @root = 'donotreply@example.com'
    end
  end
end
