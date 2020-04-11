require 'test_helper'

class Caco::Postgres::HbaSetTest < Minitest::Test
  def test_existing_value_for_local_type
    result = Caco::Postgres::HbaSet.(
      input: postgresql_content, type: "local", database: "all", user: "all", method: "trust"
    )
    assert result.success?
    refute result[:created]
    refute result[:changed]
  end

  def test_existing_value_for_host_type
    result = Caco::Postgres::HbaSet.(
      input: postgresql_content, type: "host", database: "all", user: "all", network: '127.0.0.1/32', method: "trust"
    )
    assert result.success?
    refute result[:created]
    refute result[:changed]
  end

  def test_new_value_for_local_type
    result = Caco::Postgres::HbaSet.(
      input: postgresql_content, type: "local", database: "sameuser", user: "all", method: "trust"
    )
    # Dev.wtf?(described_class, params: {
    #   input: postgresql_content, type: "local", database: "sameuser", user: "all", method: "trust"
    # })

    assert result.success?
    assert result[:created]
    assert result[:changed]
    assert result[:content].match?(/^local\s+sameuser\s+all\s+trust$/)
  end

  def test_new_value_for_host_type
    result = Caco::Postgres::HbaSet.(
      input: postgresql_content, type: "host", database: "sameuser", user: "all", network: '127.0.0.1/32', method: "trust"
    )
    # Dev.wtf?(described_class,
    #   input: postgresql_content, type: "host", database: "sameuser", user: "all", network: '127.0.0.1/32', method: "trust"
    # )
    
    assert result.success?
    assert result[:created]
    assert result[:changed]
    assert result[:content].match?(/^host\s+sameuser\s+all\s+127\.0\.0\.1\/32\s+trust$/)
  end

  def test_raise_exception_if_non_local_type_without_network
    err = assert_raises(Caco::Postgres::HbaSet::MissingNetworkValue) {
      Caco::Postgres::HbaSet.(
        input: postgresql_content, type: "host", database: "sameuser", user: "all", network: nil, method: "trust"
      )
    }
    assert_match(/You need to enter a value for network when host is specified/, err.message)
  end

  def test_raise_exception_for_invalid_type
    err = assert_raises(Caco::Postgres::HbaSet::InvalidType) {
      Caco::Postgres::HbaSet.(
        input: postgresql_content, type: "foo", database: "sameuser", user: "all", network: nil, method: "trust"
      )
    }
    assert_match(/`foo' is not a valid type/, err.message)
  end

  def test_raise_exception_for_invalid_method
    err = assert_raises(Caco::Postgres::HbaSet::InvalidMethod) {
      Caco::Postgres::HbaSet.(
        input: postgresql_content, type: "local", database: "sameuser", user: "all", network: nil, method: "foo"
      )
    }
    assert_match(/`foo' is not a valid method/, err.message)
  end

  def postgresql_content
    <<~EOF
    local   all             all                                     trust
    host    all             all             127.0.0.1/32            trust
    host    all             all             ::1/128                 trust
    local   replication     all                                     trust
    host    replication     all             127.0.0.1/32            trust
    host    replication     all             ::1/128                 trust
    EOF
  end
end
