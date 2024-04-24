require "multi_json"
require "addressfinder/version"
require "addressfinder/configuration"
require "addressfinder/verification"
require "addressfinder/v2/au/verification"
require "addressfinder/location_info"
require "addressfinder/location_search"
require "addressfinder/address_info"
require "addressfinder/address_search"
require "addressfinder/address_autocomplete"
require "addressfinder/bulk"
require "addressfinder/v1/email/verification"
require "addressfinder/v1/email/bulk_verification"
require "addressfinder/v1/phone/verification"
require "addressfinder/errors"
require "addressfinder/util"
require "addressfinder/http"

module AddressFinder
  class << self
    def configure(config_hash = nil)
      if config_hash
        config_hash.each do |k, v|
          if configuration.respond_to?(:"#{k}=")
            begin
              configuration.send(:"#{k}=", v)
            rescue
              nil
            end
          end
        end
      end

      yield(configuration) if block_given?
    end

    def configuration
      @configuration ||= AddressFinder::Configuration.new
    end

    def cleanse(args = {}) # We are keeping this method for backward compatibility
      AddressFinder::Verification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.result
    end

    def verification(args = {})
      if (args[:country] || configuration.default_country) == "au" && configuration.verification_version&.downcase == "v2"
        AddressFinder::V2::Au::Verification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.result
      else
        AddressFinder::Verification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.result
      end
    end

    def location_search(args = {})
      AddressFinder::LocationSearch.new(params: args, http: AddressFinder::HTTP.new(configuration)).perform.results
    end

    def location_info(args = {})
      AddressFinder::LocationInfo.new(params: args, http: AddressFinder::HTTP.new(configuration)).perform.result
    end

    def address_search(args = {})
      AddressFinder::AddressSearch.new(params: args, http: AddressFinder::HTTP.new(configuration)).perform.results
    end

    def address_autocomplete(args = {})
      AddressFinder::AddressAutocomplete.new(params: args, http: AddressFinder::HTTP.new(configuration)).perform.results
    end

    def address_info(args = {})
      AddressFinder::AddressInfo.new(params: args, http: AddressFinder::HTTP.new(configuration)).perform.result
    end

    def email_verification(args = {})
      AddressFinder::V1::Email::Verification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.result
    end

    def emails_verification(args = {})
      AddressFinder::V1::Email::BulkVerification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.result
    end

    def phone_verification(args = {})
      AddressFinder::V1::Phone::Verification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.result
    end

    def bulk(&)
      AddressFinder::Bulk.new(http: AddressFinder::HTTP.new(configuration), verification_version: configuration.verification_version, default_country: configuration.default_country, &).perform
    end
  end
end
