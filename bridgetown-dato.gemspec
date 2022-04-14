# frozen_string_literal: true

require_relative "lib/bridgetown-dato/version"

Gem::Specification.new do |spec|
  spec.name          = "bridgetown-dato"
  spec.version       = BridgetownDato::VERSION
  spec.author        = "Bridgetown Team"
  spec.email         = "maintainers@bridgetownrb.com"
  spec.summary       = "Sample code for creating new Bridgetown plugins"
  spec.homepage      = "https://github.com/username/bridgetown-dato"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r!^(test|script|spec|features|frontend)/!) }
  spec.test_files    = spec.files.grep(%r!^test/!)
  spec.require_paths = ["lib"]
  spec.metadata      = { "yarn-add" => "bridgetown-dato@#{BridgetownDato::VERSION}" }

  spec.required_ruby_version = ">= 3.1.0"

  spec.add_dependency "bridgetown", ">= 1.0", "< 2.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "rubocop-bridgetown", "~> 0.3"
end
