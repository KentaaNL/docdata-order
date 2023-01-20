# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'docdata/order/version'

Gem::Specification.new do |spec|
  spec.name          = 'docdata-order'
  spec.version       = Docdata::Order::VERSION
  spec.authors       = ['Kentaa']
  spec.email         = ['support@kentaa.nl']

  spec.summary       = 'Ruby client for the Docdata Order API'
  spec.homepage      = 'https://github.com/KentaaNL/docdata-order'
  spec.license       = 'MIT'

  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir['CHANGELOG.md', 'LICENSE.txt', 'README.md', 'lib/**/*']

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.0'

  spec.add_dependency 'savon', '>= 2.0', '< 3.0'
end
