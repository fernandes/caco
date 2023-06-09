# frozen_string_literal: true

# Caco Module
module Caco
  extend T::Sig

  # Nodenv Module
  module Nginx
    class Vhost
      module Cell
        class Server < Trailblazer::Cell
          property :server_name
          property :listen
          property :auth_basic
          property :auth_basic_user_file
          property :root
          property :locations
          property :returns

          property :ssl_certificate
          property :ssl_certificate_key
          property :ssl_session_cache
          property :ssl_session_timeout
          property :ssl_prefer_server_ciphers
          property :ssl_protocols
        end
      end
    end
  end
end
