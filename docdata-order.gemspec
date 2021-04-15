# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docdata/order/version'

Gem::Specification.new do |spec|
  spec.name          = "docdata-order"
  spec.version       = Docdata::Order::VERSION
  spec.authors       = ["Kentaa"]
  spec.email         = ["support@kentaa.nl"]

  spec.summary       = "Ruby client for the Docdata Order API"
  spec.homepage      = "https://github.com/KentaaNL/docdata-order"
  spec.license       = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 2.3", ">= 2.3.2"

  spec.add_dependency "savon", ">= 2.0", "< 3.0"
end
