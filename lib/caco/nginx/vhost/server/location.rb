# frozen_string_literal: true
# typed: strict

require_relative './cell/location'

# Caco Module
module Caco
  # Nodenv Module
  module Nginx
    class Vhost
      class Server
        class Location
          extend T::Sig

          sig { returns(String) }
          attr_reader :name

          sig { returns(T.nilable(String)) }
          attr_accessor :proxy_http_version

          sig { returns(T.nilable(T::Hash[String, String])) }
          attr_accessor :proxy_set_headers

          sig { returns(T.nilable(String)) }
          attr_accessor :proxy_pass

          sig { returns(T.nilable(String)) }
          attr_accessor :location

          sig { params(name: String).void }
          def initialize(name)
            @name = name
            @proxy_set_headers = {}
          end
        end
      end
    end
  end
end
