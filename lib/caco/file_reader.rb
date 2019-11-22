class Caco::FileReader < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:path)
  step Caco::Macro::NormalizeParams()
  pass :use_custom_root
  step :file_exist
  step :read_file, Output(Trailblazer::Activity::Left, :failure) => End(:success)

  def use_custom_root(ctx, path:, **)
    return false unless Caco.config.write_files_root
    ctx[:path] = "#{Caco.config.write_files_root}#{ctx[:path]}"
  end

  def file_exist(ctx, path:, **)
    ctx[:file_exist] = File.exist?(path)
  end

  def read_file(ctx, path:, **)
    ctx[:output] = File.read(path)
  end
end
