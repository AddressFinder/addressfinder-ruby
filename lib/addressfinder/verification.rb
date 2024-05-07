require "ostruct"

module AddressFinder
  class Verification
    attr_reader :result

    # AU V1 expected attributes:
    # params[:state_codes] --> string or array of strings: i.e.,['ACT', 'NSW'],
    # params[:census] --> '2011' or '2016' or nil,

    # NZ expected attributes:
    # params[:delivered] --> '0', '1', or nil,
    # params[:post_box] --> '0', '1', or nil,
    # params[:rural] --> '0', '1', or nil,
    # params[:region_code] --> string, see options on addressfinder.nz or nil,
    # params[:census] --> '2013', '2018' or nil

    # Combined attributes
    # params[:q] --> the address query,
    # params[:domain] --> used for reporting does not affect query results
    # params[:key] --> unique AddressFinder public key
    # params[:secret] --> unique AddressFinder secret key
    def initialize(q:, http:, post_box: nil, census: nil, domain: nil, key: nil, secret: nil, state_codes: nil,
      delivered: nil, rural: nil, region_code: nil, country: nil)
      @params = {}
      # Common to AU and NZ
      @params["q"] = q
      @params["post_box"] = post_box if post_box
      @params["census"] = census if census
      @params["domain"] = domain || config.domain if domain || config.domain
      @params["key"] = key || config.api_key
      @params["secret"] = secret || config.api_secret
      # AU params
      @params["state_codes"] = state_codes if state_codes
      # NZ params
      @params["delivered"] = delivered if delivered
      @params["rural"] = rural if rural
      @params["region_code"] = region_code if region_code
      @country = country || config.default_country

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

    attr_reader :request_uri, :params, :country, :http
    attr_accessor :response_body, :response_status
    attr_writer :result

    def build_request
      @request_uri = "/api/#{country}/address/verification?#{encoded_params}"
    end

    def execute_request
      request = Net::HTTP::Get.new(request_uri)

      response = http.request(request)

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
