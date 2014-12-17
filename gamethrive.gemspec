lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gamethrive/version'

Gem::Specification.new do |spec|
  spec.name          = "gamethrive"
  spec.version       = Gamethrive::VERSION
  spec.date          = "2014-12-09"
  spec.summary       = "Ruby client for Gamethrive"
  spec.description   = "A Gamethrive API client for Ruby"
  spec.authors       = ["ShowGizmo", "James Stradling"]
  spec.email         = "james@stdlng.com"
  spec.homepage      = "http://www.gamethrive.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files | grep -Ev '^(test)'`.split("\n")
  spec.test_files    = `git ls-files -- test/*`.split("\n")

  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rake"
  spec.add_runtime_dependency "faraday"
  spec.add_runtime_dependency "system_timer"
  spec.add_runtime_dependency "json"

  spec.add_development_dependency "fakeweb", ["~> 1.3"]
  spec.add_development_dependency "minitest", ["~> 4.2"]
  spec.add_development_dependency "activesupport", ["~> 3.2"]
end
