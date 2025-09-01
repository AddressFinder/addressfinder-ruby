# -*- encoding: utf-8 -*-
require File.expand_path('../lib/addressfinder/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "addressfinder"
  gem.version       = AddressFinder::VERSION
  gem.licenses      = ['MIT']
  gem.authors       = ["Nigel Ramsay", "Naiki Pohe", "Sean Arnold", "Alexandre Barret", "Cassandre Guinut"]
  gem.email         = ["nigel.ramsay@addressfinder.nz", "naiki.pohe@abletech.co.nz", "seanarnie@gmail.com", "alex@abletech.nz", "cassandre.guinut@addressfinder.nz"]
  gem.description   = %q{Ruby client library for AddressFinder}
  gem.summary       = %q{Provides easy access to AddressFinder APIs}
  gem.homepage      = "https://github.com/AddressFinder/addressfinder-ruby"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(spec|features)/})
  gem.require_paths = ["lib"]

<<<<<<< Updated upstream
  gem.required_ruby_version = '~> 2.1'
  gem.add_dependency 'multi_json', '~> 1.11'
  gem.add_development_dependency 'rspec', '~> 3.3'
  gem.add_development_dependency 'guard-rspec', '~> 4.6'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'webmock', '~> 1.21'
  gem.add_development_dependency 'listen', '~> 3.2'
=======
  gem.required_ruby_version = '>= 2.7'
  gem.add_dependency 'multi_json', '~> 1.15'
  gem.add_dependency "concurrent-ruby", "~> 1.2"
  gem.add_dependency 'ostruct', '> 0.6'
  gem.add_dependency 'cgi', '~> 0.5'


  gem.add_development_dependency 'guard-rspec', '~> 4.7'
  gem.add_development_dependency 'listen', '~> 3.7'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'rspec', '~> 3.11'
  gem.add_development_dependency 'webmock', '~> 3.25'
  gem.add_development_dependency 'debug', '>= 1.0.0'
  gem.add_development_dependency 'standard', '>= 1.35'
>>>>>>> Stashed changes
end
