class Caco::FileReader < Trailblazer::Operation
  UseCustomRoot = Class.new(Trailblazer::Activity::Signal)

  step :use_custom_root,
    Output(UseCustomRoot, :use_custom_root) => Track(:success)

  step :file_exist
  step :read_file, Output(Trailblazer::Activity::Left, :failure) => End(:success)

  def use_custom_root(ctx, path:, **)
    return true unless Caco.config.write_files_root
    ctx[:path] = "#{Caco.config.write_files_root}#{ctx[:path]}"

    UseCustomRoot
  end

  def file_exist(ctx, path:, **)
    ctx[:file_exist] = File.exist?(path)
  end

  def read_file(ctx, path:, **)
    ctx[:output] = File.read(path)
  end
end
