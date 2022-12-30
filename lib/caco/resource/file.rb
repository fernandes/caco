# typed: true
class Caco::Resource::File < Caco::Resource::Base
  include ActiveModel::Validations
  extend T::Sig

  sig {returns(String)}
  attr_accessor :content

  sig { void }
  def make_absent
    ::File.delete(path)
  end

  sig { void }
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

extend T::Sig

sig {
  params(
    name: String,
    content: String
  ).
  returns(T::Hash[String, String])
}
def file(name, content:)
  resource = Caco::Resource::File.new(name)
  resource.content = content
  unless resource.valid?
    raise Caco::Resource::Invalid.new(
      "Invalid `file' with errors: #{resource.errors.full_messages}"
    )
  end
  resource.action!
  resource.result
end

