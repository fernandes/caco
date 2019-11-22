class Caco::Haproxy::ConfSet < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:name)
  step Caco::Macro::ValidateParamPresence(:value)
  step Caco::Macro::NormalizeParams()

  step Subprocess(Caco::FileReader),
    input:  ->(_ctx, **) do { params: {
      path: "/etc/default/haproxy",
    } } end,
    output: [:output]
  step Subprocess(Caco::Haproxy::ConfGet),
    input:  ->(_ctx, name:, **) do { params: {
      name: name,
    } } end,
    output: {value: :existing_value}
  step :change_value
  fail :create_value, Output(:success) => Track(:success)

  step Subprocess(Caco::FileWriter),
    input:  ->(_ctx, new_config_content:, **) do { params: {
      path: "/etc/default/haproxy",
      content: new_config_content
    } } end

  def change_value(ctx, output:, name:, value:, **)
    ctx[:changed] = true
    ctx[:new_config_content] = output.gsub!(/^#{name}=\"(.*)\"/, "#{name}=\"#{value}\"")
    true
  end

  def create_value(ctx, output:, name:, value:, **)
    ctx[:created] = true
    output << "#{name}=\"#{value}\"\n"
    ctx[:new_config_content] = output
    true
  end
end
