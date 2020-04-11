module Caco::Rbenv
  class InstallVersion < Trailblazer::Operation
    step Subprocess(Class.new(Caco::Executer)),
      input: ->(_ctx, version:, **) {{
        command: ". /etc/profile && /opt/rbenv/bin/rbenv versions|egrep --color \"^..#{version}(\s|$)\"",
      }},
      Output(:failure) => Id(:install_version),
      id: :install_version_checker

    step Subprocess(Class.new(Caco::Executer)),
      input: ->(_ctx, version:, **) {{
        command: ". /etc/profile && /opt/rbenv/bin/rbenv install #{version}",
      }},
      id: :install_version,
      magnetic_to: nil
  end
end
