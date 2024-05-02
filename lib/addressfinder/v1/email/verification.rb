require "addressfinder/v1/base"

module AddressFinder
  module V1
    module Email
      class Verification < AddressFinder::V1::Base
        attr_reader :result

        def initialize(email:, http:, **args)
          params = {email: email}.merge(args)
          super(params: params, path: "/api/email/v1/verification", http: http)
        end
      end
    end
  end
end
