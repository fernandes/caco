module Caco::Haproxy
  class Install < Trailblazer::Operation
    step Subprocess(Caco::Debian::AptUpdate)
    step Subprocess(Caco::Debian::PackageInstall),
      input: ->(_ctx, **) {{
        package: 'haproxy'
      }}
  end
end
