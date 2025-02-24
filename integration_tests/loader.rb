require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "warning"
  gem "addressfinder", path: File.expand_path("../..", __dir__), require: false
end

Warning.process { :raise }

require 'addressfinder'
