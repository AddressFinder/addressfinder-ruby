require 'addressfinder/v1/base'

module AddressFinder
  module V1
    module Email
      class Verification < AddressFinder::V1::Base
        attr_reader :result
    
        def initialize(email:, http:, domain: nil, key: nil, secret: nil, format: nil)
          params = {}
          params[:email] = email
          params[:domain] = domain || config.domain if (domain || config.domain)
          params[:key] = key || config.api_key
          params[:secret] = secret || config.api_secret
          params[:format] = format || 'json'
  
          super(params: params, path: "/api/email/v1/verification", http: http)
        end
      end
    end
  end
end
