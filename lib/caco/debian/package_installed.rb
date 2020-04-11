module Caco::Debian
  class PackageInstalled < Trailblazer::Operation
    step Subprocess(Caco::Executer),
      input: ->(_ctx, package:, **) {{
        command: "dpkg -s #{package}"
      }},
      output: { exit_code: :command_exit_code, output: :command_output },
      id: "dpkg"

    step Subprocess(Caco::Finder),
      input: ->(_ctx, package:, **) {{
        command: "dpkg-query -W -f='${Status} ${Version}\n' #{package}",
        regexp: /^install/
      }},
      id: "dpkg_query"
  end
end
