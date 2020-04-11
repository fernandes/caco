module Caco::Grafana
  class Install < Trailblazer::Operation
    class Repo < Trailblazer::Operation
      step Subprocess(Caco::Debian::AptKeyInstall),
        input: ->(_ctx, **) {{
          url: 'https://packages.grafana.com/gpg.key',
          fingerprint: '4E40 DDF6 D76E 284A 4A67  80E4 8C8C 34C5 2409 8CB6'
        }}

      step Subprocess(Caco::Debian::AptRepoAdd),
        input: ->(_ctx, **) {{
          name: 'grafana',
          url: 'https://packages.grafana.com/oss/deb',
          release: "stable",
          component: 'main'
        }}
    end

    step Subprocess(Repo)
    step Subprocess(Caco::Debian::AptUpdate)
    step Subprocess(Caco::Debian::PackageInstall),
      input: ->(_ctx, **) {{
        package: 'grafana'
      }}
  end
end
