class Caco::FileWriter < Trailblazer::Operation
  SameMD5 = Class.new(Trailblazer::Activity::Signal)
  DifferentMD5 = Class.new(Trailblazer::Activity::Signal)
  UseCustomRoot = Class.new(Trailblazer::Activity::Signal)

  step :use_custom_root,
    Output(UseCustomRoot, :use_custom_root) => Track(:success)

  pass :file_exist
  step :calculate_md5
  step :compare_md5,
    Output(SameMD5, :same_md5) => End(:success),
    Output(DifferentMD5, :success) => Track(:success)
  step :mkdir_p
  step :write_file

  def use_custom_root(ctx, path:, **)
    return true unless Caco.config.write_files_root
    unless ctx[:path].start_with?(Caco.config.write_files_root.to_s)
      ctx[:path] = "#{Caco.config.write_files_root}#{ctx[:path]}"
    end
    UseCustomRoot
  end

  def file_exist(ctx, path:, **)
    ctx[:file_exist] = File.exist?(path)
    ctx[:file_created] = !ctx[:file_exist]
    ctx[:file_exist]
  end

  def calculate_md5(ctx, path:, file_exist:, content:, **)
    ctx[:current_md5] = (file_exist ? Digest::MD5.hexdigest(File.read(path)) : "")
    ctx[:content_md5] = Digest::MD5.hexdigest(content)
  end

  def compare_md5(ctx, content_md5:, current_md5:, **)
    different_md5 = (content_md5 != current_md5)
    ctx[:file_changed] = different_md5 ? true : false
    different_md5 ? DifferentMD5 : SameMD5
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
      File.write(path, content)
    end
    ctx[:file_created] = !file_exist
    ctx[:file_changed] = true
  end
end
