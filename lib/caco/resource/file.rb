# typed: true
class Caco::Resource::File < Caco::Resource::Base
  include ActiveModel::Validations
  extend T::Sig

  sig {returns(String)}
  attr_accessor :content

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

    # Same file we are good
    return true if file_md5 == content_md5

    if Caco.config.write_files
      FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
      File.write(path, content)
      changed!
      created! if !file_exist 
    end
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

