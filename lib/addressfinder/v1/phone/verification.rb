require 'addressfinder/v1/base'

module AddressFinder
  module V1
    module Phone
      class Verification < AddressFinder::V1::Base
        attr_reader :result
    
        def initialize(phone_number:, default_country_code:, http:, allowed_country_codes: nil, mobile_only: nil, timeout: nil, domain: nil, key: nil, secret: nil, format: nil)
          params = {}
          params[:phone_number] = phone_number
          params[:default_country_code] = default_country_code
          params[:allowed_country_codes] = allowed_country_codes if allowed_country_codes
          params[:mobile_only] = mobile_only if mobile_only
          params[:timeout] = timeout if timeout
          params[:domain] = domain || config.domain if (domain || config.domain)
          params[:key] = key || config.api_key
          params[:secret] = secret || config.api_secret
          params[:format] = format || 'json'
  
          super(params: params, path: "/api/phone/v1/verification", http: http)
        end
      end
    end
  end
end
