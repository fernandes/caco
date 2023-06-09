# frozen_string_literal: true

# Caco Module
module Caco
  extend T::Sig

  # Nodenv Module
  module Docker
    def self.install
      %w[docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin].each do |pkg|
        Caco.package(pkg)
      end

      user_on_docker_group = Etc.getgrnam('docker').mem.include?(Settings.user)
      Caco.execute('add user to docker group', command: "usermod -aG docker #{Settings.user}") unless user_on_docker_group
    end

    def self.install_official_repo
      Caco.file '/etc/apt/sources.list.d/docker.list', content: <<~CONF
        deb https://download.docker.com/linux/debian bullseye stable
      CONF

      key_installed = File.exist?('/etc/apt/trusted.gpg.d/docker.gpg')

      return if key_installed

      Caco.execute(
        'docker install repo key',
        command: 'curl -sS https://download.docker.com/linux/debian/gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/docker.gpg'
      )
    end

    # def self.ensure_running
    #   Caco.execute('nginx start', command: 'systemctl start nginx').success? unless running?
    # end
    #
    # def self.running?
    #   Caco.execute('nginx check running', command: 'systemctl status nginx').success?
    # end
    #
    # def self.ensure_enabled
    #   Caco.execute('nginx enable', command: 'systemctl enable nginx').success? unless enabled?
    # end
    #
    # def self.enabled?
    #   Caco.execute('nginx check enabled', command: 'systemctl is-enabled nginx').success?
    # end
  end
end

