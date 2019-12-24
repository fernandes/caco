module Caco
  module Prometheus
  end
end

require 'caco/prometheus/install'

# Templates
require 'caco/prometheus/cell/alertmanager_conf'
require 'caco/prometheus/cell/alerts'
require 'caco/prometheus/cell/conf'
