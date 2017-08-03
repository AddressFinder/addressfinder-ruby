require 'multi_json'
require 'addressfinder/version'
require 'addressfinder/configuration'
require 'addressfinder/cleanse'
require 'addressfinder/location_info'
require 'addressfinder/location_search'
require 'addressfinder/address_info'
require 'addressfinder/address_search'
require 'addressfinder/bulk'
require 'addressfinder/errors'
require 'addressfinder/util'
require 'addressfinder/http'

module AddressFinder
  class << self
    def configure(config_hash=nil)
      if config_hash
        config_hash.each do |k,v|
          configuration.send("#{k}=", v) rescue nil if configuration.respond_to?("#{k}=")
        end
      end

      yield(configuration) if block_given?
    end

    def configuration
      @configuration ||= AddressFinder::Configuration.new
    end

    def cleanse(args={})
      AddressFinder::Cleanse.new(args.merge(http: AddressFinder::HTTP.new(configuration))).perform.result
    end

    def location_search(args={})
      AddressFinder::LocationSearch.new(params: args, http: AddressFinder::HTTP.new(configuration)).perform.results
    end

    def location_info(args={})
      AddressFinder::LocationInfo.new(params: args, http: AddressFinder::HTTP.new(configuration)).perform.result
    end

    def address_search(args={})
      AddressFinder::AddressSearch.new(params: args, http: AddressFinder::HTTP.new(configuration)).perform.results
    end

    def address_info(args={})
      AddressFinder::AddressInfo.new(params: args, http: AddressFinder::HTTP.new(configuration)).perform.result
    end

    def bulk(&block)
      AddressFinder::Bulk.new(http: AddressFinder::HTTP.new(configuration), &block).perform
    end
  end
end
