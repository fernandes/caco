module Caco::Haproxy
  class Install < Trailblazer::Operation
    step Subprocess(Caco::Debian::AptUpdate)
    step Subprocess(Caco::Debian::PackageInstall),
      input:  ->(_ctx, **) do { params: {
        package: 'haproxy'
      }} end
  end
end
