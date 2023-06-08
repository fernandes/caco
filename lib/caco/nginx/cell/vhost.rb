# frozen_string_literal: true

# Caco Module
module Caco
  extend T::Sig

  # Nodenv Module
  module Nginx
    module Cell
      class Vhost < Trailblazer::Cell
        self.view_paths = [File.expand_path('./nodes')]

        property :name
        property :upstream
        property :servers
      end
    end
  end
end
