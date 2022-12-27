class Caco::Ssh::AuthorizedKeysAdd < Trailblazer::Operation
  step Subprocess(Caco::Debian::UserHome),
    input: ->(_ctx, user:, **) {{
      user: user
    }}

  step ->(ctx, user:, **) {
      ctx[:user_home] = "/home/#{user}"
    },
    id: :define_user_path

  step :check_user_ssh_folder

  step :check_user_ssh_authorized_keys

  step Subprocess(Caco::FileReader),
    input: ->(_ctx, user_home:, **) {{
      path: "#{user_home}/.ssh/authorized_keys",
    }},
    output: [:output]

  step ->(ctx, key:, identifier:, output:, **) {
      output.match?("^#{key} #{identifier}$")
    },
    Output(:success) => End(:success),
    Output(:failure) => Track(:success),
    id: :check_same_entry_exist

  step ->(ctx, identifier:, output:, **) {
      output.match?("^.*#{identifier}$")
    },
    Output(:success) => Id(:change_key),
    Output(:failure) => Id(:add_key),
    id: :check_identifier_exist

  step :change_key, magnetic_to: nil
  def change_key(ctx, key:, identifier:, output:, **)
    output.gsub!(/^.*#{identifier}$/, "#{key} #{identifier}")
    ctx[:content] = output
  end

  step :add_key, magnetic_to: nil
  def add_key(ctx, key:, identifier:, output:, **)
    output << "#{key} #{identifier}\n"
    ctx[:created] = true
    ctx[:content] = output
  end

  step :write_key
  step ->(ctx, **) {
      ctx[:changed] = true
    },
    id: :mark_as_changed

  def write_key(ctx, authorized_keys_path:, content:, **)
    file authorized_keys_path do |f|
      f.content = content
    end
  end

  def check_user_ssh_folder(ctx, user:, user_home:, **)
    ctx[:ssh_home] = ssh_home = "#{Caco.config.write_files_root}#{user_home}/.ssh"
    FileUtils.mkdir_p(ssh_home)
    File.chmod(0700, ssh_home)
    FileUtils.chown user, nil, ssh_home
  rescue Errno::EPERM
    true
  end

  def check_user_ssh_authorized_keys(ctx, ssh_home:, user:, **)
    ctx[:authorized_keys_path] = authorized_keys_path = "#{ssh_home}/authorized_keys"
    unless File.exist?(authorized_keys_path)
      FileUtils.touch(authorized_keys_path)
      File.chmod(0600, authorized_keys_path)
      begin
        FileUtils.chown user, nil, authorized_keys_path
      rescue Errno::EPERM
        true
      end
    else
      true
    end
  end
end
