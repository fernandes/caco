require "test_helper"

class Caco::Repmgr::Cell::ConfTest < Minitest::Test
  def test_output
    output = described_class.(node_id: 1, node_name: 'psql1', postgres_version: 12).to_s
    assert_equal output, default_output
  end

  def default_output
    <<~EOF    
    node_id=1
    node_name='psql1'
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
