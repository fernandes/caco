# Ruby Dependencies
require 'delegate'
require 'digest'
require 'json'
require 'open3'

# Gems
require 'augeas'
require 'cells-erb'
require 'config'
require 'hiera/backend/eyaml'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'
require 'trailblazer'
require 'trailblazer/cells'

# System
require "caco/config"
require "caco/executer"
require "caco/facter"
require "caco/file_writer"
require "caco/finder"
require "caco/macro"
require "caco/settings_loader"
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
