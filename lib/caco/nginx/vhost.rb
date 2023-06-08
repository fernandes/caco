# frozen_string_literal: true
# typed: strict

require_relative './vhost/server'
require_relative './cell/vhost'

# Caco Module
module Caco
  extend T::Sig

  # Nodenv Module
  module Nginx
    class Vhost
      extend T::Sig

      sig { returns(String) }
      attr_reader :name

      sig { returns(T.nilable(Caco::Nginx::Upstream)) }
      attr_reader :upstream

      sig { returns(T::Array[Server]) }
      attr_reader :servers


      sig { params(name: String).void }
      def initialize(name)
        @name = name
        @servers = T.let([], T::Array[Server])
      end

      sig { params(upstream: Caco::Nginx::Upstream).returns(T::Boolean) }
      def upstream=(upstream)
        @upstream = T.let(upstream, T.nilable(Caco::Nginx::Upstream))
        true
      end

      sig { returns(Caco::Resource::Result) }
      def apply
        content = Caco::Nginx::Cell::Vhost.call(self).to_s
        Caco.file("/etc/nginx/conf.d/#{file_name}.conf", content: content)
      end

      sig { returns(String) }
      def file_name
        name
      end

      sig { params(server_name: String, listen: T.any(String, Integer), block: T.proc.params(arg0: Server).void).returns(Server) }
      def server(server_name, listen:, &block)
        new_server = Server.new(server_name: server_name, listen: listen)
        new_server.tap do |server|
          block.call(server)
        end
        servers.append new_server
        new_server
      end
    end
  end
end
