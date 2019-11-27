require "test_helper"

class Caco::Repmgr::NodeRegisterPrimaryTest < Minitest::Test
  def test_register
    returns = [
      [[true, 0, cluster_show_output_clean], ["su - postgres -c 'repmgr cluster show --compact'"]],
      [[true, 0, ""], ["su - postgres -c 'repmgr primary register'"]]
    ]

    executer_stub(returns) do
      result = described_class.(params: { node_name: "db1" })
      assert result.success?
    end
  end

  def test_register_already_registered_as_primary
    returns = [
      [[true, 0, cluster_show_output_primary], ["su - postgres -c 'repmgr cluster show --compact'"]],
    ]

    executer_stub(returns) do
      result = described_class.(params: { node_name: "db1" })
      assert result.success?
    end
  end

  def test_register_already_registered_as_standby
    returns = [
      [[true, 0, cluster_show_output_standby], ["su - postgres -c 'repmgr cluster show --compact'"]],
    ]

    executer_stub(returns) do
      result = described_class.(params: { node_name: "db1" })
      assert result.failure?
    end
  end

  def test_register_with_another_primary
    returns = [
      [[true, 0, cluster_show_output_primary], ["su - postgres -c 'repmgr cluster show --compact'"]],
    ]

    executer_stub(returns) do
      result = described_class.(params: { node_name: "db2" })
      assert result.failure?
    end
  end

  def cluster_show_output_clean
    <<~EOF
     ID | Name | Role    | Status    | Upstream | Location | Prio. | TLI
    ----+------+---------+-----------+----------+----------+-------+-----
    EOF
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
