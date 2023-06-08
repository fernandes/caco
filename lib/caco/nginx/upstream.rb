# frozen_string_literal: true
# typed: strict

require_relative './cell/upstream'

# Caco Module
module Caco
  # Nodenv Module
  module Nginx
    class Upstream
      extend T::Sig

      sig { returns(String) }
      attr_reader :name

      sig { returns(T::Array[String]) }
      attr_reader :servers

      sig { params(name: String).void }
      def initialize(name)
        @name = name
        @servers = T.let([], T::Array[String])
      end
    end
  end
end
