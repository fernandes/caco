require "test_helper"

class Caco::Repmgr::NodeRoleTest < Minitest::Test
  def test_node_primary
    returns = [
      [[true, 0, cluster_show_output_primary], ["su - postgres -c 'repmgr cluster show --compact'"]],
    ]

    executer_stub(returns) do
      # Dev.wtf?(described_class, {})
      result = described_class.(params: { node_name: "db1" })
      assert result.success?
      assert_equal "primary", result[:node_role]
    end
  end

  def test_node_unregistered
    returns = [
      [[true, 0, cluster_show_output_standby], ["su - postgres -c 'repmgr cluster show --compact'"]],
    ]

    executer_stub(returns) do
      # Dev.wtf?(described_class, {})
      result = described_class.(params: { node_name: "db1" })
      assert result.success?
      assert_equal "standby", result[:node_role]
    end
  end
  
  def test_node_unknown
    returns = [
      [[true, 0, cluster_show_output_standby], ["su - postgres -c 'repmgr cluster show --compact'"]],
    ]

    executer_stub(returns) do
      # Dev.wtf?(described_class, {})
      result = described_class.(params: { node_name: "db2" })
      refute result.success?
    end
  end

  def cluster_show_output_primary
    <<~EOF
     ID | Name | Role    | Status    | Upstream | Location | Prio. | TLI
    ----+------+---------+-----------+----------+----------+-------+-----
     1  | db1  | primary | * running |          | default  | 100   | 11  
    EOF
  end

  def cluster_show_output_standby
    <<~EOF
     ID | Name | Role    | Status    | Upstream | Location | Prio. | TLI
    ----+------+---------+-----------+----------+----------+-------+-----
     1  | db1  | standby | * running |          | default  | 100   | 11  
    EOF
  end
end
