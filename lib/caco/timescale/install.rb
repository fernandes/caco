module Caco::Timescale
  class Install < Trailblazer::Operation
    class Repo < Trailblazer::Operation
      step Subprocess(Caco::Debian::AptKeyInstall),
        input: ->(_ctx, **) {{
          url: 'https://packagecloud.io/timescale/timescaledb/gpgkey',
          fingerprint: '1005 FB68 604C E9B8 F687  9CF7 59F1 8EDF 47F2 4417'
        }}
      step Subprocess(Caco::Debian::AptRepoAdd),
        input: ->(_ctx, **) {{
          name: 'timescale',
          url: 'https://packagecloud.io/timescale/timescaledb/debian/',
          release: "#{Caco::Facter.("os", "distro", "codename")}",
          component: 'main'
        }}
    end

    step Subprocess(Repo)
    step Subprocess(Caco::Debian::AptUpdate)
    step Subprocess(Caco::Debian::PackageInstall),
      input: ->(_ctx, postgres_version:, **) {{
        package: "timescaledb-postgresql-#{postgres_version}"
      }}
  end
end
