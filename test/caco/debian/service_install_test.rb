require "test_helper"

class Caco::Debian::ServiceInstallTest < Minitest::Test
  def setup
    clean_tmp_path
    @service_unit_path = "#{TMP_PATH}/etc/systemd/system/sidekiq.service"
  end

  def test_dpkg_and_query_installed
    returns = [
      [[true, 0, ""], ['systemctl daemon-reload']],
    ]

    executer_stub(returns) do
      params = { params: { name: "sidekiq", command: "/var/app/bin/bundle exec sidekiq" } }
      # Dev.wtf?(described_class, params)
      result = described_class.(params)
      assert result.success?
      assert_equal stub_system_unit_test, File.read(@service_unit_path)
    end
  end

  def stub_system_unit_test
    <<~EOF
    # File Managed, Dot Not Edit
    [Unit]
    Description=No Description Provided
    After=syslog.target network.target network-online.target

    [Service]
    User=root
    Restart=on-failure
    ExecStart=/var/app/bin/bundle exec sidekiq
    
    [Install]
    WantedBy=multi-user.target
    EOF
  end
end
