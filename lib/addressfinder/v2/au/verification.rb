require "ostruct"

module AddressFinder
  module V2
    module Au
      class Verification
        attr_reader :result

        # V2 AU expected attributes:
        # params[:q] --> the address query,
        # params[:post_box] --> nil or '0'
        # params[:census] --> '2011' or '2016' or nil,
        # params[:domain] --> used for reporting does not affect query results
        # params[:key] --> unique AddressFinder public key
        # params[:secret] --> unique AddressFinder secret key
        # params[:paf] --> nil or '1',
        # params[:gnaf] --> nil or '1',
        # params[:gps] --> nil or '1',
        # params[:extended] --> nil or '1',
        # params[:state_codes] --> string or array of strings: i.e.,['ACT', 'NSW'],
        def initialize(q:, http:, post_box: nil, census: nil, domain: nil, key: nil, secret: nil, paf: nil, gnaf: nil,
          gps: nil, state_codes: nil, extended: nil, country: nil)
          @params = {}
          @params["q"] = q
          @params["post_box"] = post_box if post_box
          @params["census"] = census if census
          @params["domain"] = domain || config.domain if domain || config.domain
          @params["key"] = key || config.api_key
          @params["secret"] = secret || config.api_secret
          @params["paf"] = paf if paf
          @params["gnaf"] = gnaf if gnaf
          @params["gps"] = gps if gps
          @params["extended"] = extended if extended
          @params["state_codes"] = state_codes if state_codes

          @params["format"] = "json"
          @http = http
        end

        def perform
          build_request
          execute_request
          build_result

          self
        end

        private

        attr_reader :request_uri, :params, :http
        attr_accessor :response_body, :response_status
        attr_writer :result

        def build_request
          @request_uri = "/api/au/address/v2/verification?#{encoded_params}"
        end

        def execute_request
          response = http.request(request_uri)

          self.response_body = response.body
          self.response_status = response.code
        end

        def build_result
          raise AddressFinder::RequestRejectedError.new(@response_status, @response_body) if response_status != "200"

          self.result = if response_hash["matched"]
            Result.new(response_hash["address"] || response_hash)
          end
        end

        def encoded_params
          Util.encode_and_join_params(params)
        end

        def response_hash
          @_response_hash ||= MultiJson.load(response_body)
        end

        def config
          @_config ||= AddressFinder.configuration
        end

        class Result < OpenStruct
        end
      end
    end
  end
end
