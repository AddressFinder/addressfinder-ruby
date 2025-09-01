require "multi_json"
require "concurrent/executor/fixed_thread_pool"
require "concurrent/array"
require "addressfinder/version"
require "addressfinder/configuration"
require "addressfinder/verification"
require "addressfinder/v1/nz/batch_verification"
require "addressfinder/v2/au/verification"
require "addressfinder/v2/au/batch_verification"
require "addressfinder/location_info"
require "addressfinder/location_search"
require "addressfinder/address_info"
require "addressfinder/address_search"
require "addressfinder/address_autocomplete"
require "addressfinder/bulk"
require "addressfinder/v1/email/verification"
require "addressfinder/v1/email/batch_verification"
require "addressfinder/v1/phone/verification"
require "addressfinder/v1/phone/batch_verification"
require "addressfinder/errors"
require "addressfinder/util"
require "addressfinder/http"

module AddressFinder
  class << self
    def configure(config_hash = nil)
      config_hash&.each do |k, v|
        next unless configuration.respond_to?(:"#{k}=")

        begin
          configuration.send(:"#{k}=", v)
        rescue
          nil
        end
      end

      yield(configuration) if block_given?
    end

    def configuration
      @configuration ||= AddressFinder::Configuration.new
    end

    def address_verification(args = {})
      if (args[:country] || configuration.default_country) == "au" && configuration.verification_version&.downcase == "v2"
        AddressFinder::V2::Au::Verification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.result
      else
        AddressFinder::Verification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.result
      end
    end

    def verification(args = {}) # We are keeping this method for backward compatibility
      address_verification(args)
    end

    def cleanse(args = {}) # We are keeping this method for backward compatibility
      address_verification(args)
    end

    def address_verification_nz_batch(args = {})
      AddressFinder::V1::Nz::BatchVerification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.results
    end

    def address_verification_au_batch(args = {})
      AddressFinder::V2::Au::BatchVerification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.results
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

    def email_verification_batch(args = {})
      AddressFinder::V1::Email::BatchVerification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.results
    end

    def phone_verification(args = {})
      AddressFinder::V1::Phone::Verification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.result
    end

    def phone_verification_batch(args = {})
      AddressFinder::V1::Phone::BatchVerification.new(**args.merge(http: AddressFinder::HTTP.new(configuration))).perform.results
    end

    def bulk(&block)
      AddressFinder::Bulk.new(
        http: AddressFinder::HTTP.new(configuration), verification_version: configuration.verification_version, default_country: configuration.default_country, &block
      ).perform
    end
  end
end
