# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'roda/plugins/basic_auth/version'

Gem::Specification.new do |spec|
  spec.name          = "roda-basic-auth"
  spec.version       = Roda::RodaPlugins::BasicAuth::VERSION
  spec.authors       = ["Amadeus Folego"]
  spec.email         = ["amadeusfolego@gmail.com"]

  spec.summary       = %q{Adds basic authentication methods to Roda}
  spec.description   = %q{Adds basic authentication methods to Roda}
  spec.homepage      = "https://github.com/badosu/roda-basic-auth"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency "roda", ">= 2.0", "< 4.0"
  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.10"
  spec.add_development_dependency "rack-test", "0.7.0"
end
