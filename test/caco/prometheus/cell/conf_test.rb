require "test_helper"

class Caco::Prometheus::Cell::ConfTest < Minitest::Test
  def test_output
    output = described_class.(root: "/etc/prometheus").to_s
    assert_equal output, default_output
  end

  def default_output
    <<~EOF    
    global:
      scrape_interval:     15s
      evaluation_interval: 15s

    remote_write:
      - url: "http://127.0.0.1:9201/write"
    remote_read:
      - url: "http://127.0.0.1:9201/read"

    rule_files:
      - /etc/prometheus/alerts.d/*.rules

    alerting:
      alertmanagers:
      - static_configs:
        - targets:
          - localhost:9093

    scrape_configs:
      - job_name: prometheus
        static_configs:
          - targets: ['localhost:9090']
      - job_name: postgresql
        static_configs:
          - targets: ['localhost:9187']
      - job_name: postgresql_adapter
        static_configs:
          - targets: ['localhost:9201']
      - job_name: node_exporter
        scrape_interval: 1m
        scrape_timeout:  1m
        metrics_path: '/metrics'
        static_configs: 
          - targets: ['localhost:9100']
    EOF
  end
end
