require 'addressfinder/v1/base'

module AddressFinder
  module V1
    module Phone
      class Verification < AddressFinder::V1::Base
        attr_reader :result
    
        def initialize(phone_number:, default_country_code:, http:, **args)
          params = {phone_number: phone_number, default_country_code: default_country_code}.merge(args)
          super(params: params, path: "/api/phone/v1/verification", http: http)
        end
      end
    end
  end
end
