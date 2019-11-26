class Caco::Ssh::AuthorizedKeysAdd < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:user)
  step Caco::Macro::ValidateParamPresence(:identifier)
  step Caco::Macro::ValidateParamPresence(:key)
  step Caco::Macro::NormalizeParams()
  step :define_user_path
  step :check_user_ssh_folder
  step :check_user_ssh_authorized_keys
  step Subprocess(Caco::FileReader),
    input:  ->(_ctx, user_home:, **) do { params: {
      path: "#{user_home}/.ssh/authorized_keys",
    } } end,
    output: [:output]
  step :check_same_entry_exist,
    Output(:success) => End(:success),
    Output(:failure) => Track(:success)
  step :check_identifier_exist,
    Output(:success) => Id(:change_key),
    Output(:failure) => Id(:add_key)
  step :change_key, magnetic_to: nil
  step :add_key, magnetic_to: nil
  step Subprocess(Caco::FileWriter),
    input:  ->(_ctx, authorized_keys_path:, content:, **) do { params: {
      path: authorized_keys_path,
      content: content
    } } end
  step :mark_as_changed
  
  def define_user_path(ctx, user:, **)
    ctx[:user_home] = "/home/fernandes"
  end

  def check_user_ssh_folder(ctx, user:, user_home:, **)
    ctx[:ssh_home] = ssh_home = "#{Caco.config.write_files_root}#{user_home}/.ssh"
    FileUtils.mkdir_p(ssh_home)
    File.chmod(0700, ssh_home)
    FileUtils.chown user, nil, ssh_home
  end

  def check_user_ssh_authorized_keys(ctx, ssh_home:, user:, **)
    ctx[:authorized_keys_path] = authorized_keys_path = "#{ssh_home}/authorized_keys"
    unless File.exist?(authorized_keys_path)
      FileUtils.touch(authorized_keys_path)
      File.chmod(0600, authorized_keys_path)
      FileUtils.chown user, nil, authorized_keys_path
    else
      true
    end
  end

  def check_same_entry_exist(ctx, key:, identifier:, output:, **)
    output.match?("^#{key} #{identifier}$")
  end

  def check_identifier_exist(ctx, key:, identifier:, output:, **)
    output.match?("^.*#{identifier}$")
  end

  def add_key(ctx, key:, identifier:, output:, **)
    output << "#{key} #{identifier}\n"
    ctx[:created] = true
    ctx[:content] = output
  end

  def change_key(ctx, key:, identifier:, output:, **)
    output.gsub!(/^.*#{identifier}$/, "#{key} #{identifier}")
    ctx[:content] = output
  end

  def mark_as_changed(ctx, **)
    ctx[:changed] = true
  end
end
