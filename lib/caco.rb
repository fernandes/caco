# Ruby Dependencies
require 'delegate'
require 'digest'
require 'json'
require 'open3'

# Gems
require 'augeas'
require 'cells-erb'
require 'config'
require 'down'
require 'down/http'
Down.backend Down::Http

require 'hiera/backend/eyaml'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/parser/parser'
require 'marcel'
require 'trailblazer'
require 'trailblazer/cells'

# System (order dependant)
require "caco/config"
require "caco/macro"
require "caco/executer"

require "caco/facter"
require "caco/file_writer"
require "caco/file_link"
require "caco/downloader"
require "caco/finder"
require "caco/unpacker"
require "caco/settings_loader"
require "caco/version"

# modules
require "caco/debian"

require "caco/barman"
require "caco/haproxy"
require "caco/postgres"
require "caco/prometheus"
require "caco/rbenv"
require "caco/repmgr"

module Caco
  class << self
    attr_accessor :root
  end

  class Error < StandardError; end
  # Your code goes here...
end

class Trailblazer::Cell
  include Cell::Erb
  self.view_paths = [File.expand_path("../", __FILE__)]

  def property(key)
    return nil if model.nil?
    return nil unless model.has_key?(key) and model.is_a?(Hash)
    return model[key]
  end
end

class Trailblazer::Operation
  class InvalidParam < StandardError; end

  def p(message)
    method_name = (caller[0] =~ /`([^']*)'/ and $1)
    puts "#{self.class}##{method_name}: #{message}"
  end
end

def trbreaks(klass = nil)
  bind_to = klass.nil? ? self.class : klass
  bind_to.instance_methods(false).each do |m|
    Pry::Byebug::Breakpoints.add_method("#{bind_to}##{m}")
  end
  true
end
