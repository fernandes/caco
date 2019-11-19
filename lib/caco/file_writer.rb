class Caco::FileWriter < Trailblazer::Operation
  step :file_exist
  step :calculate_md5
  step :compare_md5, Output(Trailblazer::Activity::Left, :failure) => End(:success)
  step :write_file

  def file_exist(ctx, params:, **)
    ctx[:file_exist] = File.exist?(params[:path])
    true
  end

  def calculate_md5(ctx, params:, file_exist:, **)
    ctx[:current_md5] = (file_exist ? Digest::MD5.hexdigest(File.read(params[:path])) : "")
    ctx[:content_md5] = Digest::MD5.hexdigest(params[:content])
    true
  end

  def compare_md5(ctx, params:, file_exist:, **)
    ctx[:content_md5] != ctx[:current_md5]
  end

  def write_file(ctx, params:, **)
    File.open(params[:path], File::RDWR|File::CREAT, 0644) do |f|
      f.write(params[:content])
    end
    ctx[:file_changed] = true
  end
end
