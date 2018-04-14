
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "action_throttling/version"

Gem::Specification.new do |spec|
  spec.name          = "rails-action_throttling"
  spec.version       = ActionThrottling::VERSION
  spec.authors       = ["Emil Kampp"]
  spec.email         = ["emil@kampp.me"]

  spec.summary       = "Rails per-action request throttling"
  spec.description   = "Allows request throttling on a per-action basis"
  spec.homepage      = "https://github.com/YouWeApS/arctic-gems-rails-action_throttling"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "timecop", "~> 0.9"
  spec.add_runtime_dependency "http-errors", "~> 0.1"
  spec.add_runtime_dependency "activesupport", "~> 5.2"
  spec.add_runtime_dependency "redis", "~> 4.0"
end
