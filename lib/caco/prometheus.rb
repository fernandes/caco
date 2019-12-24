module Caco
  module Prometheus
  end
end

require 'caco/prometheus/adapter_install_pg'
require 'caco/prometheus/adapter_install_postgresql'
require 'caco/prometheus/exporter_install'
require 'caco/prometheus/install'
require 'caco/prometheus/install_alert_manager'

# Templates
require 'caco/prometheus/cell/alertmanager_conf'
require 'caco/prometheus/cell/alerts'
require 'caco/prometheus/cell/conf'
