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
      end
    end
  end
end
