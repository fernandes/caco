class Caco::Debian::AptKeyInstall < Trailblazer::Operation
  step Subprocess(Caco::Executer),
    Output(:failure) => Track(:success),
    Output(:success) => End(:success),
    input: ->(_ctx, fingerprint:, **) {{
      command: "apt-key list|egrep -i '#{fingerprint}'"
    }},
    output: { check_key_exist_exit_code: :exit_code, check_key_exist_output: :output },
    id: :check_key_exist

  step Subprocess(Class.new(Caco::Executer)),
    input: ->(_ctx, url:, **) {{
      command: "wget -q -O - #{url} | apt-key add -"
    }},
    output: ->(_ctx, exit_code:, output:, **) {{
      install_key_exit_code: exit_code, install_key_output: output, apt_key_executed: true
    }},
    id: :install_key
end
