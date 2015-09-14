# -*- encoding: utf-8 -*-
require File.expand_path('../lib/addressfinder/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "addressfinder"
  gem.version       = AddressFinder::VERSION
  gem.authors       = ["Nigel Ramsay"]
  gem.email         = ["nigel@abletech.nz"]
  gem.description   = %q{Ruby client library for AddressFinder}
  gem.summary       = %q{Provides easy access to AddressFinder APIs}
  gem.homepage      = "https://github.com/AbleTech/addressfinder-ruby"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '~> 2.1'
  gem.add_runtime_dependency 'multi_json', '~> 1.0'

  gem.add_development_dependency 'rspec', '>= 3.3.0'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'webmock'
end
