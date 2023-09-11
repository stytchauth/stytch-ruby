# frozen_string_literal: true

require_relative 'lib/stytch/version'

Gem::Specification.new do |spec|
  spec.name          = 'stytch'
  spec.version       = Stytch::VERSION
  spec.authors       = ['stytch']
  spec.email         = ['support@stytch.com']

  spec.summary       = 'Stytch Ruby Gem'
  spec.homepage      = 'https://stytch.com'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/stytchauth/stytch-ruby'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '>= 2.0.1', '< 3.0'
  spec.add_dependency 'json-jwt', '>= 1.13.0'
  spec.add_dependency 'jwt', '>= 2.3.0'

  spec.add_development_dependency 'rspec', '~> 3.11.0'
  spec.add_development_dependency 'rubocop', '1.56.3'
  spec.add_development_dependency 'rubocop-rspec', '2.24.0'
end
