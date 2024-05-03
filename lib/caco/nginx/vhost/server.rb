# frozen_string_literal: true
# typed: strict

require_relative './server/location'
require_relative './cell/server'

# Caco Module
module Caco
  # Nodenv Module
  module Nginx
    class Vhost
      class Server
        extend T::Sig

        sig { returns(String) }
        attr_reader :server_name

        sig { returns(T.any(String, Integer)) }
        attr_reader :listen

        sig { returns(T.nilable(String)) }
        attr_accessor :auth_basic

        sig { returns(T.nilable(String)) }
        attr_accessor :auth_basic_user_file

        sig { returns(T.nilable(String)) }
        attr_accessor :root

        sig { returns(T::Array[Location]) }
        attr_reader :locations

        sig { returns(T.nilable(String)) }
        attr_accessor :return

        sig { returns(T.nilable(String)) }
        attr_accessor :ssl_certificate

        sig { returns(T.nilable(String)) }
        attr_accessor :ssl_certificate_key

        sig { returns(T.nilable(String)) }
        attr_accessor :ssl_session_cache

        sig { returns(T.nilable(String)) }
        attr_accessor :ssl_session_timeout

        sig { returns(T.nilable(String)) }
        attr_accessor :ssl_prefer_server_ciphers

        sig { returns(T.nilable(String)) }
        attr_accessor :ssl_protocols

        sig { returns(T.nilable(String)) }
        attr_accessor :proxy_busy_buffers_size

        sig { returns(T.nilable(String)) }
        attr_accessor :proxy_buffers

        sig { returns(T.nilable(String)) }
        attr_accessor :proxy_buffer_size

        sig { params(server_name: String, listen: T.any(String, Integer)).void }
        def initialize(server_name:, listen: 443)
          @server_name = server_name
          @listen = listen
          @locations = T.let([], T::Array[Location])
        end

        sig { params(name: String, block: T.proc.params(arg0: Location).void).returns(Location) }
        def location(name, &block)
          new_location = Location.new(name)
          new_location.tap do |location|
            block.call(location)
          end
          @locations.append new_location
          new_location
        end
      end
    end
  end
end
