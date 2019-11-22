class Caco::Debian::AptKeyInstall < Trailblazer::Operation
  step Caco::Macro::ValidateParamPresence(:url)
  step Caco::Macro::ValidateParamPresence(:fingerprint)
  step Caco::Macro::NormalizeParams()
  step Subprocess(Caco::Executer),
    input: :check_key_exist_input,
    output: :check_key_exist_output,
    id: "check_key_exist",
    Output(:failure) => Track(:success),
    Output(:success) => End(:success)
  
  step Subprocess(Class.new(Caco::Executer)),
    input: :install_key_input,
    output: :install_key_output,
    id: "install_key"
  
  def check_key_exist_input(original_ctx, fingerprint:, **)
    { params: { command: "apt-key list|egrep -i '#{fingerprint}'" } }
  end

  def check_key_exist_output(scoped_ctx, exit_code:, output:, **)
    { check_key_exist_exit_code: exit_code, check_key_exist_output: output }
  end

  def install_key_input(original_ctx, url:, **)
    { params: { command: "wget -q -O - #{url} | apt-key add -" } }
  end

  def install_key_output(scoped_ctx, exit_code:, output:, **)
    { install_key_exit_code: exit_code, install_key_output: output, apt_key_executed: true }
  end
end
