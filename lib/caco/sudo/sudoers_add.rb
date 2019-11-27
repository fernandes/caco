module Caco::Sudo
  class SudoersAdd < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:identifier)
    step Caco::Macro::ValidateParamPresence(:content)
    step Caco::Macro::NormalizeParams()
    step :build_path
    step Subprocess(Caco::FileWriter),
    input:  ->(_ctx, path:, content:, **) do { params: {
      path: path,
      content: content
    } } end,
    output: {file_created: :created, file_changed: :changed}


    def build_path(ctx, identifier:, **)
      ctx[:path] = "/etc/sudoers.d/#{identifier}"
    end
  end
end
