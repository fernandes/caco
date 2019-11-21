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
    attr_accessor :write_files

    def initialize
      @root = 'donotreply@example.com'
      @write_files = true
    end
  end
end
