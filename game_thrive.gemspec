lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'game_thrive/version'

Gem::Specification.new do |spec|
  spec.name                   = "game_thrive"
  spec.version                = GameThrive::VERSION
  spec.date                   = "2015-01-05"
  spec.summary                = "Ruby client for GameThrive"
  spec.description            = "A GameThrive API client for Ruby"
  spec.authors                = ["ShowGizmo", "James Stradling"]
  spec.email                  = "james@strdlng.com"
  spec.homepage               = "http://www.gamethrive.com"
  spec.license                = "MIT"
  spec.required_ruby_version  = '>= 1.9.3'

  spec.files         = `git ls-files | grep -Ev '^(test)'`.split("\n")
  spec.test_files    = `git ls-files -- test/*`.split("\n")

  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rake"
  spec.add_runtime_dependency "faraday"
  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "activesupport", [">= 3.1"]

  spec.add_development_dependency "fakeweb", [">= 1.3"]
  spec.add_development_dependency "minitest", [">= 4.2"]
end
