class Caco::Resource::File < Caco::Resource::Base
  attr_accessor :content
  
  def make_absent
    File.rm(path)
  end

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
  def path
    return name unless Caco.config.write_files_root
    unless name.start_with?(Caco.config.write_files_root.to_s)
      return "#{Caco.config.write_files_root}#{name}"
    end
    name
  end
end

# make_dsl(:file, Caco::Resource::File)

def file(name, **kwargs, &block)
  resource = Caco::Resource::File.new(name)
  kwargs.each_pair do |k, v|
    resource.send("#{k}=", v)
  end
  # resource.instance_eval(&block)
  resource.action!
  resource.result
end
