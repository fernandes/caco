require "test_helper"

class Caco::Repmgr::ConfTest < Minitest::Test
  def setup
    clean_tmp_path
  end

  def test_add_sudoers_file
    params = {node_id: 1, node_name: "db1", postgres_version: 12}
    # Dev.wtf?(described_class, params)
    result = described_class.call(**params)
    assert result.success?
    assert result[:created]
    assert result[:changed]

    # Test File Config
    result = Caco::FileReader.call(path: "/etc/repmgr.conf")
    assert_equal config_content, result[:output]
  end

  def test_change_sudoers_file
    params = {node_id: 1, node_name: "dbX", postgres_version: 12}
    described_class.call(**params)

    params = {node_id: 1, node_name: "db1", postgres_version: 12}
    result = described_class.call(**params)
    assert result.success?
    refute result[:created]
    assert result[:changed]

    # Test File Config
    result = Caco::FileReader.call(path: "/etc/repmgr.conf")
    assert_equal config_content, result[:output]
  end

  def config_content
    <<~EOF
      node_id=1
      node_name='db1'
      conninfo='host= user= dbname= connect_timeout=2'
      data_directory='/var/lib/postgresql/12/main'

      use_replication_slots=yes
      monitoring_history=yes

      service_start_command   = 'sudo /usr/bin/pg_ctlcluster 12 main start'
      service_stop_command    = 'sudo /usr/bin/pg_ctlcluster 12 main stop'
      service_restart_command = 'sudo /usr/bin/pg_ctlcluster 12 main restart'
      service_reload_command  = 'sudo /usr/bin/pg_ctlcluster 12 main reload'
      service_promote_command = 'sudo /usr/bin/pg_ctlcluster 12 main promote'

      promote_check_timeout = 15

      failover=automatic
      promote_command='/usr/bin/repmgr standby promote -f /etc/repmgr.conf --log-to-file'
      follow_command='/usr/bin/repmgr standby follow -f /etc/repmgr.conf --log-to-file --upstream-node-id=%n'

      log_file='/var/log/postgresql/repmgrd.log'

    EOF
  end
end
