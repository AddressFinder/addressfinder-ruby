require 'addressfinder/version'
require 'addressfinder/configuration'
require 'addressfinder/cleanse'
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

    def cleanse(*args)
      AddressFinder::Cleanse.new(*args).perform
    end
  end
end
