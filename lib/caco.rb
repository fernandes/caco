require "zeitwerk"
require "zeitwerk/gem_inflector"
class CacoZeitwerkInflector < Zeitwerk::GemInflector
  def camelize(basename, abspath)
    if basename == "os"
      "OS"
    else
      super
    end
  end
end

loader = Zeitwerk::Loader.for_gem
loader.inflector = CacoZeitwerkInflector.new(__FILE__)
loader.setup # ready!

# loader.inflector.inflect "os" => "OS"

def require_path(path)
  Dir["#{path}/*.rb"].each { |file| require file }
end

# Ruby Dependencies
require "digest"
require "erb"
require "json"
require "open3"
require "sorbet-runtime"

# Gems
require "active_support"
require "active_model"
require "augeas"
require "cells-erb"
require "config"
require "declarative"
# Monkey Patching to remove !Warning!
Declarative::Defaults.class_eval do
  alias_method :handle_array_and_deprecate_orig, :handle_array_and_deprecate
  remove_method :handle_array_and_deprecate
  def handle_array_and_deprecate(variables)
    wrapped = Declarative::Defaults.wrap_arrays(variables)

    variables.merge(wrapped)
  end
end

require "down"
require "down/http"
Down.backend Down::Http

require "hiera/backend/eyaml"
require "hiera/backend/eyaml/options"
require "hiera/backend/eyaml/parser/parser"
require "marcel"
require "trailblazer"
require "trailblazer/cells"

require "caco/configuration"
require "caco/settings_loader"

module Caco
  extend Dsl

  class << self
    attr_accessor :root
  end

  class Error < StandardError; end
  # Your code goes here...

  class FixtureNotExist < StandardError; end
end

module Cell
  # Erb contains helpers that are messed up in Rails and do escaping.
  Erb.class_eval do
    alias_method :template_options_for_orig, :template_options_for
    remove_method :template_options_for

    def template_options_for(_options)
      {
        template_class: ::Tilt::ERBTemplate,
        escape_html: false,
        escape_attrs: false,
        suffix: "erb",
        trim: true
      }
    end
  end
end

class Trailblazer::Cell
  include Cell::Erb
  self.view_paths = [File.expand_path("../", __FILE__)]

  def property(key)
    return nil if model.nil?
    return nil unless model.has_key?(key) and model.is_a?(Hash)
    model[key]
  end
end

class Trailblazer::Operation
  class InvalidParam < StandardError; end

  def p(message)
    method_name = (caller(1..1).first =~ /`([^']*)'/ and $1)
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

loader.eager_load
