# -*- encoding: utf-8 -*-
require File.expand_path('../lib/addressfinder/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "addressfinder"
  gem.version       = AddressFinder::VERSION
  gem.licenses      = ['MIT']
  gem.authors       = ["Nigel Ramsay", "Naiki Pohe", "Sean Arnold", "Alexandre Barret"]
  gem.email         = ["nigel.ramsay@abletech.co.nz", "naiki.pohe@abletech.co.nz", "seanarnie@gmail.com", "alex@abletech.nz"]
  gem.description   = %q{Ruby client library for AddressFinder}
  gem.summary       = %q{Provides easy access to AddressFinder APIs}
  gem.homepage      = "https://github.com/AbleTech/addressfinder-ruby"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec|features)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '~> 2.1'
  gem.add_dependency 'multi_json', '~> 1.11'
  gem.add_development_dependency 'rspec', '~> 3.3'
  gem.add_development_dependency 'guard-rspec', '~> 4.6'
  gem.add_development_dependency 'rake', '~> 10.4'
  gem.add_development_dependency 'webmock', '~> 1.21'
end
