# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `cells-erb` gem.
# Please instead update this file by running `bin/tapioca gem cells-erb`.

module Cell; end

# Erb contains helpers that are messed up in Rails and do escaping.
module Cell::Erb
  # @yield [args]
  #
  # source://cells-erb//lib/cell/erb/template.rb#13
  def capture(*args); end

  # source://cells-erb//lib/cell/erb/template.rb#39
  def concat(string); end

  # Below:
  # Rails specific helper fixes. I hate that. I can't tell you how much I hate those helpers,
  # and their blind escaping for every possible string within the application.
  #
  # source://cells-erb//lib/cell/erb/template.rb#20
  def content_tag(name, content_or_options_with_block = T.unsafe(nil), options = T.unsafe(nil), escape = T.unsafe(nil), &block); end

  # source://cells-erb//lib/cell/erb/template.rb#34
  def form_tag_html(html_options); end

  # source://cells-erb//lib/cell/erb/template.rb#30
  def form_tag_with_body(html_options, content); end

  # We do statically set escape=true since attributes are double-quoted strings, so we have
  # to escape (default in Rails).
  #
  # source://cells-erb//lib/cell/erb/template.rb#26
  def tag_options(options, escape = T.unsafe(nil)); end

  # source://caco/0.1.0/lib/caco.rb#76
  def template_options_for(_options); end
end

# Erbse-Tilt binding. This should be bundled with tilt. # 1.4. OR should be tilt-erbse.
class Cell::Erb::Template < ::Tilt::Template
  # source://cells-erb//lib/cell/erb/template.rb#51
  def initialize_engine; end

  # source://cells-erb//lib/cell/erb/template.rb#59
  def precompiled_template(locals); end

  # source://cells-erb//lib/cell/erb/template.rb#55
  def prepare; end

  class << self
    # @return [Boolean]
    #
    # source://cells-erb//lib/cell/erb/template.rb#47
    def engine_initialized?; end
  end
end

# source://cells/4.1.7/lib/cell/version.rb#2
Cell::VERSION = T.let(T.unsafe(nil), String)
