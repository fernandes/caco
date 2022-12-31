module Caco::Sudo
  class SudoersAdd < Trailblazer::Operation
    step ->(ctx, identifier:, **) {
        ctx[:path] = "/etc/sudoers.d/#{identifier}"
      },
      id: :build_path

    step :write_file,
      input: ->(_ctx, path:, content:, **) {{
        path: path,
        content: content
      }}

    def write_file(ctx, path:, content:, **)
      result = Caco.file path, content: content

      ctx[:created] = result[:created]
      ctx[:changed] = result[:changed]
      true
    end
  end
end
