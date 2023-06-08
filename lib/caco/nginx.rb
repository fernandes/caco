# frozen_string_literal: true
require_relative "./nginx/upstream"
require_relative "./nginx/vhost"

# Caco Module
module Caco
  extend T::Sig

  # Nodenv Module
  module Nginx
    def self.install
      Caco.package('nginx')
    end

    def self.install_official_repo
      Caco.file '/etc/apt/sources.list.d/nginx.list', content: <<~CONF
        deb https://nginx.org/packages/debian/ bullseye nginx
        deb-src https://nginx.org/packages/debian/ bullseye nginx
      CONF

      key_installed = File.exist?('/etc/apt/trusted.gpg.d/nginx.gpg')

      return if key_installed

      Caco.execute(
        'nginx install repo key',
        command: 'curl -sS https://download.docker.com/linux/debian/gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/docker.gpg'
      )
    end

    def self.ensure_running
      Caco.execute('nginx start', command: 'systemctl start nginx').success? unless running?
    end

    def self.running?
      Caco.execute('nginx check running', command: 'systemctl status nginx').success?
    end

    def self.ensure_enabled
      Caco.execute('nginx enable', command: 'systemctl enable nginx').success? unless enabled?
    end

    def self.enabled?
      Caco.execute('nginx check enabled', command: 'systemctl is-enabled nginx').success?
    end
  end
end
