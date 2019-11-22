require "test_helper"

class Caco::Prometheus::Cell::AlertsTest < Minitest::Test
  def test_output
    output = described_class.().to_s
    assert_equal output, default_output
  end

  def default_output
    <<~EOF    
    groups:
    - name: alert.rules
      rules:
      - alert: EndpointDown
        expr: probe_success == 0
        for: 10s
        labels:
          severity: 'critical'
        annotations:
          summary: 'Endpoint down'
      - alert: ExporterDown
        expr: up == 0
        for: 1m
        labels:
          severity: warning
        annotations:
          summary: 'Exporter down (instance {{ $labels.instance }})'
          description: 'Prometheus exporter down\\n  VALUE = {{ $value }}\\n  LABELS: {{ $labels }}'
    EOF
  end
end
