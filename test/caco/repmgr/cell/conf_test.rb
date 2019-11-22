require "test_helper"

class Caco::Repmgr::Cell::ConfTest < Minitest::Test
  def test_output
    output = described_class.().to_s
    assert_equal output, default_output
  end

  def default_output
    <<~EOF    
    node_id=node_name=''
    conninfo='host= user= dbname= connect_timeout=2'
    data_directory='/var/lib/postgresql//main'

    use_replication_slots=yes
    monitoring_history=yes

    service_start_command   = 'sudo /usr/bin/pg_ctlcluster  main start'
    service_stop_command    = 'sudo /usr/bin/pg_ctlcluster  main stop'
    service_restart_command = 'sudo /usr/bin/pg_ctlcluster  main restart'
    service_reload_command  = 'sudo /usr/bin/pg_ctlcluster  main reload'
    service_promote_command = 'sudo /usr/bin/pg_ctlcluster  main promote'

    promote_check_timeout = 15

    failover=automatic
    promote_command='/usr/bin/repmgr standby promote -f /etc/repmgr.conf --log-to-file'
    follow_command='/usr/bin/repmgr standby follow -f /etc/repmgr.conf --log-to-file --upstream-node-id=%n'

    log_file='/var/log/postgresql/repmgrd.log'

    EOF
  end
end
