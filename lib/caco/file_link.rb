class Caco::FileLink < Trailblazer::Operation
  pass :link_exist?
  pass :target_exist?
  step :link_same_target?,
    Output(:success) => End(:success),
    Output(:failure) => Track(:success)
  step :ensure_target!
  step :create_link!

  def link_exist?(ctx, link:, **)
    ctx[:link_exist] = !!File.lstat(link) rescue false
    ctx[:link_realpath] = File.realdirpath(link) rescue false
    ctx[:link_exist]
  end

  def target_exist?(ctx, target:, **)
    ctx[:target_exist] = File.exist?(target)
    ctx[:target_realpath] = File.realdirpath(target) rescue nil
    ctx[:target_exist]
  end

  def link_same_target?(ctx, target_realpath:, link_realpath:, **)
    ctx[:link_same_target] = (target_realpath == link_realpath)
  end

  def ensure_target!(ctx, target_exist:, ensure_target: false, **)
    return false if !target_exist && ensure_target
    true
  end

  def create_link!(ctx, target:, link:, link_exist:, link_same_target:, **)
    ctx[:force] = (link_exist && !link_same_target)
    FileUtils.ln_s target, link, force: ctx[:force]
    ctx[:link_created] = true
  end
end
