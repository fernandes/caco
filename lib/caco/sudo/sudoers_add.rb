module Caco::Sudo
  class SudoersAdd < Trailblazer::Operation
    step ->(ctx, identifier:, **) {
        ctx[:path] = "/etc/sudoers.d/#{identifier}"
      },
      id: :build_path

    step Subprocess(Caco::FileWriter),
      input: ->(_ctx, path:, content:, **) {{
        path: path,
        content: content
      }},
      output: {file_created: :created, file_changed: :changed}
  end
end
