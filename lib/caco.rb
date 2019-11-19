require 'delegate'
require 'augeas'
require 'config'
require 'cells-erb'
require 'digest'
require 'json'
require 'open3'

require 'trailblazer'
require 'trailblazer/cells'

# system
require "caco/config"
require "caco/executer"
require "caco/facter"
require "caco/file_writer"
require "caco/finder"
require "caco/macro"
require "caco/version"

# modules
require "caco/debian"
require "caco/postgres"
require "caco/rbenv"

module Caco
  class << self
    attr_accessor :root
  end

  class Error < StandardError; end
  # Your code goes here...
end

class Trailblazer::Cell
  include Cell::Erb
  self.view_paths = ["lib"]
end

class Trailblazer::Operation
  class InvalidParam < StandardError; end
end
