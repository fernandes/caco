
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "caco/version"

Gem::Specification.new do |spec|
  spec.name          = "caco"
  spec.version       = Caco::VERSION
  spec.authors       = ["Celso Fernandes"]
  spec.email         = ["celso.fernandes@gmail.com"]

  spec.summary       = %q{Caco, The Frog}
  spec.description   = %q{Caco, configure your machines like you develop your web apps}
  spec.homepage      = "https://github.com/fernandes/caco"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "activemodel"
  spec.add_dependency "cells", "~> 4.1"
  spec.add_dependency "cells-erb", "~> 0.1"
  spec.add_dependency "config"
  spec.add_dependency "down", "~> 5.4"
  spec.add_dependency "hiera-eyaml"
  spec.add_dependency "http", "~> 5.2"
  spec.add_dependency "marcel"
  spec.add_dependency "ruby-augeas"
  spec.add_dependency "sorbet-static-and-runtime"
  spec.add_dependency "trailblazer", "~> 2.1"
  spec.add_dependency "trailblazer-cells"
  spec.add_dependency "zeitwerk"
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "fakefs"
  spec.add_development_dependency "minitest", "~> 5.25"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "rake", "~> 13.2"
  spec.add_development_dependency "tapioca"
  spec.add_development_dependency "trailblazer-developer"
  spec.add_development_dependency "webmock"
end
