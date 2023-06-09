# frozen_string_literal: true

# Caco Module
module Caco
  extend T::Sig

  # Nodenv Module
  module Nginx
    class Vhost
      class Server
        module Cell
          class Location < Trailblazer::Cell
            property :name
            property :proxy_http_version
            property :proxy_set_headers
            property :proxy_pass
            property :location

            def location_path
              location || name
            end
          end
        end
      end
    end
  end
end
