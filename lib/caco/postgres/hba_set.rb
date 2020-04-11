class Caco::Postgres::HbaSet < Trailblazer::Operation
  class InvalidType < StandardError; end
  class InvalidMethod < StandardError; end
  class MissingNetworkValue < StandardError; end
  ValidTypes = %w( local host hostssl hostnossl )
  ValidMethods = %w( trust reject md5 password scram-sha-256 gss sspi ident peer pam ldap radius or cert )

  TypeLocal = Class.new(Trailblazer::Activity::Signal)
  TypeHost = Class.new(Trailblazer::Activity::Signal)

  step :check_type_is_valid
  step :check_method_is_valid
  step :check_value_exist,
    Output(:success) => End(:success),
    Output(:failure) => Track(:success)
  step :check_if_network_value_is_needed
  step :append_value
  step ->(ctx, **) {
      ctx[:created] = ctx[:changed] = true
    },
    id: :mark_as_changed

  def check_type_is_valid(ctx, type:, **)
    raise InvalidType.new("`#{type}' is not a valid type") unless ValidTypes.include?(type)
    true
  end

  def check_method_is_valid(ctx, method:, **)
    raise InvalidMethod.new("`#{method}' is not a valid method") unless ValidMethods.include?(method)
    true
  end

  def check_value_exist(ctx, input:, type:, database:, user:, method:, **)
    return input.match?(/^#{type}\s+#{database}\s+#{user}\s+#{method}$/) if type == 'local'
    input.match?(/^#{type}\s+#{database}\s+#{user}\s+#{ctx[:network]}\s+#{method}$/)
  end

  def check_if_network_value_is_needed(ctx, type:, **)
    return true if type == 'local'
    return true if ctx[:network]
    raise MissingNetworkValue.new("You need to enter a value for network when #{type} is specified")
  end

  def append_value(ctx, input:, type:, database:, user:, method:, **)
    after_type_size = 8 - type.size > 0 ? (8 - type.size) : 1
    after_type_spaces = " " * after_type_size

    after_db_size = 16 - database.size > 0 ? (16 - database.size) : 1
    after_db_spaces = " " * after_db_size

    after_user_size = 16 - user.size > 0 ? (16 - user.size) : 1
    after_user_spaces = " " * after_user_size

    network_size = ctx[:network].size rescue 0
    after_network_size = 24 - network_size > 0 ? 24 - network_size : 1
    after_network_spaces = " " * after_network_size

    if type == 'local'
      input << "#{type}#{after_type_spaces}#{database}#{after_db_spaces}#{user}#{after_user_spaces}#{after_network_spaces}#{method}\n"
    else
      input << "#{type}#{after_type_spaces}#{database}#{after_db_spaces}#{user}#{after_user_spaces}#{ctx[:network]}#{after_network_spaces}#{method}\n"
    end
    ctx[:content] = input
  end
end
