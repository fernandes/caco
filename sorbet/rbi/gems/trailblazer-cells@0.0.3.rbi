# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `trailblazer-cells` gem.
# Please instead update this file by running `bin/tapioca gem trailblazer-cells`.

# @abstract It cannot be directly instantiated. Subclasses must implement the `abstract` methods below.
class Trailblazer::Cell < ::Cell::ViewModel
  include ::Cell::ViewModel::Layout::External
  include ::Cell::Erb
  extend ::Trailblazer::Cell::ViewName::Path

  # TODO: test me.
  #
  # source://cells/4.1.7/lib/cell/view_model.rb#64
  def concept(name, model = T.unsafe(nil), options = T.unsafe(nil)); end

  # source://caco/0.1.0/lib/caco.rb#91
  def property(key); end

  # Comment::Cell::Show #=> show
  #
  # source://trailblazer-cells//lib/trailblazer/cell.rb#51
  def state_for_implicit_render(options); end

  class << self
    # source://trailblazer-cells//lib/trailblazer/cell.rb#30
    def class_from_cell_name(name); end

    # Comment::Cell::Show #=> comment/view/
    #
    # source://trailblazer-cells//lib/trailblazer/cell.rb#35
    def controller_path; end

    # source://trailblazer-cells//lib/trailblazer/cell.rb#43
    def view_name; end

    # source://trailblazer-cells//lib/trailblazer/cell.rb#39
    def views_dir; end
  end
end

module Trailblazer::Cell::ViewName; end

# View name is last segment, resulting in flat view hierarchy.
#   Comment::Cell::Theme::Sidebar => "sidebar.haml"
module Trailblazer::Cell::ViewName::Flat
  # source://trailblazer-cells//lib/trailblazer/cell.rb#21
  def _view_name; end
end

# View name is everything behind the last `Cell::`.
#   Comment::Cell::Theme::Sidebar => "theme/sidebar.haml"
module Trailblazer::Cell::ViewName::Path
  # source://trailblazer-cells//lib/trailblazer/cell.rb#12
  def _view_name; end
end

module Trailblazer::Cells; end

# source://trailblazer-cells//lib/trailblazer/cells/version.rb#3
Trailblazer::Cells::VERSION = T.let(T.unsafe(nil), String)