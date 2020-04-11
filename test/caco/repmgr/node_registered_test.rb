require "test_helper"

class Caco::Repmgr::NodeRegisteredTest < Minitest::Test
  def test_node_registered
    returns = [
      [[true, 0, cluster_show_output_registered], ["su - postgres -c 'repmgr cluster show --compact'"]],
    ]

    executer_stub(returns) do
      # Dev.wtf?(described_class, {})
      result = described_class.(node_name: "db2")
      assert result.success?
      assert result[:node_registered]
    end
  end

  def test_node_unregistered
    returns = [
      [[true, 0, cluster_show_output_unregistered], ["su - postgres -c 'repmgr cluster show --compact'"]],
    ]

    executer_stub(returns) do
      # Dev.wtf?(described_class, {})
      result = described_class.(node_name: "db2")
      assert result.failure?
      refute result[:node_registered]
    end
  end

  def cluster_show_output_registered
    <<~EOF
     ID | Name | Role    | Status    | Upstream | Location | Prio. | TLI
    ----+------+---------+-----------+----------+----------+-------+-----
     1  | db1  | primary | * running |          | default  | 100   | 11  
     2  | db2  | standby | ! running | db1      | default  | 100   | 11     
    EOF
  end

  def cluster_show_output_unregistered
    <<~EOF
     ID | Name | Role    | Status    | Upstream | Location | Prio. | TLI
    ----+------+---------+-----------+----------+----------+-------+-----
     1  | db1  | primary | * running |          | default  | 100   | 11  
    EOF
  end
end
