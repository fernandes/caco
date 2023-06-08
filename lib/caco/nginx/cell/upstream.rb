# frozen_string_literal: true

# Caco Module
module Caco
  extend T::Sig

  # Nodenv Module
  module Nginx
    module Cell
      class Upstream < Trailblazer::Cell
        property :name
        property :servers

        self.view_paths = [File.expand_path('./nodes')]
      end
    end
  end
end
