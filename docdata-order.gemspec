# frozen_string_literal: true

require_relative 'lib/docdata/order/version'

Gem::Specification.new do |spec|
  spec.name          = 'docdata-order'
  spec.version       = Docdata::Order::VERSION
  spec.authors       = %w[Kentaa iRaiser]
  spec.email         = ['tech-arnhem@iraiser.eu']

  spec.summary       = 'Ruby client for the Docdata Order API'
  spec.homepage      = 'https://github.com/KentaaNL/docdata-order'
  spec.license       = 'MIT'

  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  spec.files         = Dir['CHANGELOG.md', 'LICENSE.txt', 'README.md', 'lib/**/*']

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 3.2.0'

  spec.add_development_dependency 'bundler', '~> 2.5'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.0'

  spec.add_dependency 'bigdecimal'
  spec.add_dependency 'savon', '>= 2.0', '< 3.0'
end
