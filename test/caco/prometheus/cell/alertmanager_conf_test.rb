require "test_helper"

class Caco::Prometheus::Cell::AlertmanagerConfTest < Minitest::Test
  def test_output
    output = described_class.().to_s
    assert_equal output, default_output
  end

  def default_output
    <<~EOF    
    global:
      slack_api_url: 'https://hooks.slack.com/services/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'

    route:
      receiver: 'slack-notifications'
      group_by: [alertname, datacenter, app]

    receivers:
    - name: 'slack-notifications'
      slack_configs:
      - send_resolved: true
      - channel: '#monitoring'
        text: 'https://internal.myorg.net/wiki/alerts/{{ .GroupLabels.app }}/{{ .GroupLabels.alertname }}'
    EOF
  end
end
