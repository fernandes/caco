module Caco::Postgres
  class Install < Trailblazer::Operation
    class Repo < Trailblazer::Operation
      step Subprocess(Caco::Debian::AptKeyInstall),
        input:  ->(_ctx, **) do { params: {
          url: 'https://www.postgresql.org/media/keys/ACCC4CF8.asc',
          fingerprint: 'B97B 0AFC AA1A 47F0 44F2  44A0 7FCC 7D46 ACCC 4CF8'
        } } end
      step Subprocess(Caco::Debian::AptRepoAdd),
        input:  ->(_ctx, **) do { params: {
          name: 'pgdg',
          url: 'http://apt.postgresql.org/pub/repos/apt/',
          release: "#{Caco::Facter.("os", "distro", "codename")}-pgdg",
          component: 'main'
        }} end
    end

    step Subprocess(Repo)
    step Subprocess(Caco::Debian::AptUpdate)
    step Subprocess(Caco::Debian::PackageInstall),
      input:  ->(_ctx, **) do { params: {
        package: 'postgresql-server-12'
      }} end,
      id: :install_server

    pass ->(ctx, **){ ctx.to_hash.dig(:params, :install_dev_package) }, Output(:success) => Id(:install_dev_package)
    step Subprocess(Class.new(Caco::Debian::PackageInstall)),
      input:  ->(_ctx, **) do { params: {
        package: 'postgresql-server-dev-12'
      }} end,
      id: :install_dev_package,
      magnetic_to: nil
  end
end
