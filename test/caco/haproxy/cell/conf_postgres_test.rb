require "test_helper"

class Caco::Haproxy::Cell::ConfPostgresTest < Minitest::Test
  def test_output
    output = described_class.().to_s
    assert_equal output, default_output
  end

  def default_output
    <<~EOF    
    listen  haproxy_10.0.0.30_3307_rw
      bind *:3307
      mode tcp
      timeout client  10800s
      timeout server  10800s
      tcp-check expect string primary\\ is\\ running
      balance leastconn
      option tcp-check
      option allbackups
      default-server port 9300 inter 2s downinter 5s rise 3 fall 2 slowstart 60s maxconn 64 maxqueue 128 weight 100
      server 10.0.0.21 10.0.0.21:5432 check
      server 10.0.0.22 10.0.0.22:5432 check

    listen  haproxy_10.0.0.30_3308_ro
      bind *:3308
      mode tcp
      timeout client  10800s
      timeout server  10800s
      tcp-check expect string is\\ running.
      balance leastconn
      option tcp-check
      option allbackups
      default-server port 9300 inter 2s downinter 5s rise 3 fall 2 slowstart 60s maxconn 64 maxqueue 128 weight 100
      server 10.0.0.21 10.0.0.21:5432 check
      server 10.0.0.22 10.0.0.22:5432 check
    EOF
  end
end
