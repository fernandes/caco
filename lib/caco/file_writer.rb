class Caco::FileWriter < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:path)
  step Caco::Macro::ValidateParamPresence(:content)
  step Caco::Macro::NormalizeParams()
  pass :use_custom_root
  pass :file_exist
  step :calculate_md5
  step :compare_md5, Output(Trailblazer::Activity::Left, :failure) => End(:success)
  step :mkdir_p
  step :write_file

  def use_custom_root(ctx, path:, **)
    return false unless Caco.config.write_files_root
    unless ctx[:path].start_with?(Caco.config.write_files_root.to_s)
      ctx[:path] = "#{Caco.config.write_files_root}#{ctx[:path]}"
    end
  end

  def file_exist(ctx, path:, **)
    ctx[:file_exist] = File.exist?(path)
  end

  def calculate_md5(ctx, path:, file_exist:, content:, **)
    ctx[:current_md5] = (file_exist ? Digest::MD5.hexdigest(File.read(path)) : "")
    ctx[:content_md5] = Digest::MD5.hexdigest(content)
  end

  def compare_md5(ctx, content_md5:, current_md5:, **)
    content_md5 != current_md5
  end

  def mkdir_p(ctx, path:, **)
    dirname = File.dirname(path)
    if Caco.config.write_files
      FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
    end
    true
  end

  def write_file(ctx, path:, content:, file_exist:, **)
    if Caco.config.write_files
      File.open(path, File::RDWR|File::CREAT, 0644) do |f|
        f.write(content)
      end
    end
    ctx[:file_created] = !file_exist
    ctx[:file_changed] = true
  end
end
