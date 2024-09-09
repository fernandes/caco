require "test_helper"

class Caco::Debian::ServiceInstallTest < Minitest::Test
  def setup
    clean_tmp_path
    @service_unit_path = "#{TMP_PATH}/etc/systemd/system/sidekiq.service"
  end

  def test_install_service
    returns = [
      [[true, 0, ""], ["systemctl daemon-reload"]]
    ]

    executer_stub(returns) do
      params = {name: "sidekiq", command: "/var/app/bin/bundle exec sidekiq"}
      # Dev.wtf?(described_class, params)
      result = described_class.call(**params)
      assert result.success?
      assert_equal stub_system_unit_test, File.read(@service_unit_path)
    end
  end

  def test_install_service_with_environment_file
    returns = [
      [[true, 0, ""], ["systemctl daemon-reload"]]
    ]

    executer_stub(returns) do
      params = {name: "sidekiq", command: "/var/app/bin/bundle exec sidekiq", environment_file: "/etc/default/sidekiq"}
      # Dev.wtf?(described_class, params)
      result = described_class.call(**params)
      assert result.success?
      assert_equal stub_system_unit_test_with_environment_file, File.read(@service_unit_path)
    end
  end

  def test_install_service_with_environment_variables
    returns = [
      [[true, 0, ""], ["systemctl daemon-reload"]]
    ]

    executer_stub(returns) do
      params = {
        name: "sidekiq",
        command: "/var/app/bin/bundle exec sidekiq",
        environment_vars: ["Var1=Value1", "Var2=Value2"]
      }
      # Dev.wtf?(described_class, params)
      result = described_class.call(**params)
      assert result.success?
      assert_equal stub_system_unit_test_with_environment_vars, File.read(@service_unit_path)
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

  def stub_system_unit_test_with_environment_file
    <<~EOF
      # File Managed, Dot Not Edit
      [Unit]
      Description=No Description Provided
      After=syslog.target network.target network-online.target

      [Service]
      EnvironmentFile=/etc/default/sidekiq
      User=root
      Restart=on-failure
      ExecStart=/var/app/bin/bundle exec sidekiq
      
      [Install]
      WantedBy=multi-user.target
    EOF
  end

  def stub_system_unit_test_with_environment_vars
    <<~EOF
      # File Managed, Dot Not Edit
      [Unit]
      Description=No Description Provided
      After=syslog.target network.target network-online.target

      [Service]
      Environment=Var1=Value1
      Environment=Var2=Value2
      User=root
      Restart=on-failure
      ExecStart=/var/app/bin/bundle exec sidekiq
      
      [Install]
      WantedBy=multi-user.target
    EOF
  end
end
