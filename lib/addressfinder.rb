require 'net/http'
require 'multi_json'
require 'addressfinder/version'
require 'addressfinder/configuration'
require 'addressfinder/cleanse'
require 'addressfinder/location_info'
require 'addressfinder/bulk'
require 'addressfinder/errors'

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
      AddressFinder::Cleanse.new(args.merge(http: configure_http)).perform.result
    end

    def location_info(args={})
      AddressFinder::LocationInfo.new(args.merge(http: configure_http)).perform.result
    end

    def bulk(&block)
      # TODO include parameter http: configure_http
      AddressFinder::Bulk.new(&block).perform
    end

    private

    def configure_http
      http = Net::HTTP.new(configuration.hostname, configuration.port,
                           configuration.proxy_host, configuration.proxy_port,
                           configuration.proxy_user, configuration.proxy_password)
      http.open_timeout = configuration.timeout
      http.read_timeout = configuration.timeout
      http.use_ssl = true

      http
    end
  end
end
