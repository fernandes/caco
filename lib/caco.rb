require 'augeas'
require 'cells-erb'
require 'digest'
require 'json'
require 'open3'

# Call `SimpleDelegator` to avoid bug on travis
SimpleDelegator

require 'trailblazer'
require 'trailblazer/cells'

# system
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
