class Caco::Haproxy::ConfGet < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:name)
  step Caco::Macro::NormalizeParams()

  step Subprocess(Caco::FileReader),
    input:  ->(_ctx, **) do { params: {
      path: "/etc/default/haproxy",
    } } end,
    output: [:output]
  step :find_value

  def find_value(ctx, name:, output:, **)
    match = output.match(/^#{name}=\"(.*)\"/)
    return false unless match

    ctx[:value] = match[1]
  end
end
