module Caco::Repmgr
  class Install < Trailblazer::Operation
    class Repo < Trailblazer::Operation
      step Subprocess(Caco::Debian::AptKeyInstall),
        input: ->(_ctx, **) {{
          url: 'https://dl.2ndquadrant.com/gpg-key.asc',
          fingerprint: '8565 305C EA7D 0B66 4933  D250 9904 CD4B D6BA F0C3'
        }}
      step Subprocess(Caco::Debian::AptRepoAdd),
        input: ->(_ctx, **) {{
          name: '2ndquadrant-dl-default-release',
          url: 'https://dl.2ndquadrant.com/default/release/apt',
          release: "#{Caco::Facter.("os", "distro", "codename")}-2ndquadrant",
          component: 'main'
        }}
    end

    step Subprocess(Repo)
    step Subprocess(Caco::Debian::AptUpdate)
    step Subprocess(Caco::Debian::PackageInstall),
      input: ->(_ctx, **) {{
        package: 'repmgr'
      }}
  end
end
