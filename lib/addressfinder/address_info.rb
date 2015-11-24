require 'ostruct'

module AddressFinder
  class AddressInfo

    attr_reader :result

    def initialize(params:, http:)
      @http = http
      @country = params.delete(:country) || config.default_country

      @params = params
      @params['key'] = params.delete(:key) || config.api_key
      @params['secret'] = params.delete(:secret) || config.api_secret
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
      @request_uri = "/api/#{country}/address/info.json?#{encoded_params}"
    end

    def encoded_params
      query = params.map{|k,v| "#{k}=#{v}"}.join('&')
      URI::encode(query)
    end

    def execute_request
      request = Net::HTTP::Get.new(request_uri)

      response = http.request(request)

      self.response_body = response.body
      self.response_status = response.code
    end

    def build_result
      case response_status
      when '200'
        self.result = Result.new(response_hash)
      when '404'
        raise AddressFinder::NotFoundError.new(@response_status, @response_body, @pxid)
      else
        raise AddressFinder::RequestRejectedError.new(@response_status, @response_body)
      end
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
