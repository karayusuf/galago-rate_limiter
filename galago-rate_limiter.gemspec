# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "galago-rate_limiter"
  spec.version       = "0.0.1"
  spec.authors       = ["Joe Karayusuf"]
  spec.email         = ["jkarayusuf@gmail.com"]
  spec.summary       = %q{GitHub style API Rate limiter}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/*.rb']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "dalli"
end
