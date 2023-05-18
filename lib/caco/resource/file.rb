# frozen_string_literal: true
# typed: true
class Caco::Resource::File < Caco::Resource::Base
  include ActiveModel::Validations
  extend T::Sig

  sig { returns(T.nilable(String)) }
  attr_accessor :content

  sig { returns(T.nilable(String)) }
  attr_accessor :owner

  sig { returns(T.nilable(String)) }
  attr_accessor :group

  sig { returns(T.nilable(Integer)) }
  attr_accessor :mode

  sig { override.void }
  def make_absent
    ::File.delete(path) if File.exist?(path)
    FileUtils.remove_dir(path) if File.directory?(path)
  end

  sig { override.void }
  def make_present
    return make_file if guard == :present
    return make_directory if guard == :directory
  end

  sig { returns(T::Boolean) }
  def make_directory
    unless File.exist?(path)
      FileUtils.mkdir_p(path)
      created!
    end

    set_owner(path, T.cast(owner, String)) if owner
    set_group(path, T.cast(group, String)) if group
    set_mode(path, T.cast(mode, Integer)) if mode

    true
  end


  sig { returns(T::Boolean) }
  def make_file
    dirname = File.dirname(path)
    file_exist = File.exist?(path)

    # Calculate MD5
    if content
      content_md5 = Digest::MD5.hexdigest(content)
      file_md5 = (file_exist ? Digest::MD5.hexdigest(File.read(path)) : '')
    end

    dirname_created = false

    if Caco.config.write_files && file_md5 != content_md5
      unless File.exist?(dirname)
        FileUtils.mkdir_p(dirname)
        dirname_created = true
      end
      File.write(path, content) if content
      changed!
      created! unless file_exist
    end

    if owner
      set_owner(path, T.cast(owner, String))
      set_owner(dirname, T.cast(owner, String)) if dirname_created
    end

    set_group(path, T.cast(group, String)) if group
    set_mode(path, T.cast(mode, Integer)) if mode
    true
  end

  sig { params(path: String, owner: String).void }
  def set_owner(path, owner)
    current_uid = File.stat(path).uid
    future_uid = begin
      Etc.getpwnam(owner)&.uid
    rescue ArgumentError
      nil
    end

    File.chown(future_uid, nil, path) if future_uid && (current_uid != future_uid)
  end

  sig { params(path: String, group: String).void }
  def set_group(path, group)
    current_gid = File.stat(path).gid
    future_gid = begin
      # gid method does exist
      # https://ruby-doc.org/stdlib-2.7.5/libdoc/etc/rdoc/Etc.html#group
      # but sorbet is having a hard time with it
      T.unsafe(Etc.getgrnam(group))&.gid
    rescue ArgumentError
      nil
    end

    File.chown(nil, future_gid, path) unless future_gid && current_gid == future_gid
  end

  sig { params(path: String, mode: Integer).void }
  def set_mode(path, mode)
    same_mode = format('%o', File.stat(path).mode)[-4..] == mode.to_s
    File.chmod(mode, path) unless same_mode
  end

  private

  sig { returns(String) }
  def path
    return name unless Caco.config.write_files_root
    return "#{Caco.config.write_files_root}#{name}" unless name.start_with?(Caco.config.write_files_root.to_s)

    name
  end
end
