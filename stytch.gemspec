require_relative 'lib/stytch/version'

Gem::Specification.new do |spec|
  spec.name          = "stytch"
  spec.version       = Stytch::VERSION
  spec.authors       = ["alex-stytch"]
  spec.email         = ["alex@stytch.com"]

  spec.summary       = "Stytch Ruby Gem"
  spec.homepage      = "https://stytch.com"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/stytchauth/stytch-ruby"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '~> 1.1.0'
  spec.add_dependency 'faraday_middleware', '~> 1.0.0'
end
