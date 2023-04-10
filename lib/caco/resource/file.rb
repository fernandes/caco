# typed: true
class Caco::Resource::File < Caco::Resource::Base
  include ActiveModel::Validations
  extend T::Sig

  sig {returns(String)}
  attr_accessor :content

  sig {returns(T.nilable(String))}
  attr_accessor :owner

  sig {returns(T.nilable(String))}
  attr_accessor :group

  sig {returns(T.nilable(Integer))}
  attr_accessor :mode

  sig { override.void }
  def make_absent
    ::File.delete(path) if File.exist?(path)
    FileUtils.remove_dir(path) if File.directory?(path)
  end

  sig { override.void }
  def make_present
    dirname = File.dirname(path)
    file_exist = File.exist?(path)
  
    # Calculate MD5
    content_md5 = Digest::MD5.hexdigest(content)
    file_md5 = (file_exist ? Digest::MD5.hexdigest(File.read(path)) : "")

    dirname_created = false

    if Caco.config.write_files && file_md5 != content_md5
      unless File.exist?(dirname)
        FileUtils.mkdir_p(dirname)
        dirname_created = true
      end
      File.write(path, content)
      changed!
      created! if !file_exist 
    end

    if owner
      current_uid = File.stat(path).uid
      future_uid = begin
        Etc.getpwnam(owner).uid
      rescue ArgumentError
        nil
      end

      if future_uid && current_uid != future_uid
        File.chown(future_uid, nil, path)
        File.chown(future_uid, nil, dirname) if dirname_created
      end
    end

    if group
      current_gid = File.stat(path).gid
      future_gid = begin
        Etc.getgrnam(group).gid
      rescue ArgumentError
        nil
      end

      File.chown(nil, future_gid, path) if future_gid && current_gid != future_gid
    end

    if mode
      same_mode = format('%o', File.stat(path).mode)[-4..] == mode.to_s
      File.chmod(mode, path) unless same_mode
    end

    true
  end

  private
  sig { returns(String) }
  def path
    return name unless Caco.config.write_files_root
    unless name.start_with?(Caco.config.write_files_root.to_s)
      return "#{Caco.config.write_files_root}#{name}"
    end
    name
  end
end

