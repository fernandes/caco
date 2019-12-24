module Caco::Rbenv
  class InstallVersion < Trailblazer::Operation
    step Caco::Macro::ValidateParamPresence(:version)
    step Caco::Macro::NormalizeParams()

    step Subprocess(Class.new(Caco::Executer)),
      input:  ->(_ctx, version:, **) do { params: {
        command: "rbenv versions|egrep --color \"^..#{version}(\s|$)\"",
      } } end,
      Output(:failure) => Id(:install_version),
      id: :install_version_checker

    step Subprocess(Class.new(Caco::Executer)),
      input:  ->(_ctx, version:, **) do { params: {
        command: "rbenv install #{version}",
      } } end,
      id: :install_version,
      magnetic_to: nil
  end
end
