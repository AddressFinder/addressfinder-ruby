require 'ostruct'

module AddressFinder
  class Cleanse

    attr_reader :result

    def initialize(q:, country: nil, delivered: nil, post_box: nil, rural: nil, region_code: nil, domain: nil, key: nil, secret: nil, http:)
      @params = {}
      @params['q'] = q
      @params['delivered'] = delivered if delivered
      @params['post_box'] = post_box if post_box
      @params['rural'] = rural if rural
      @params['region_code'] = region_code if region_code
      @params['domain'] = domain || config.domain if (domain || config.domain)
      @params['format'] = 'json'
      @params['key'] = key || config.api_key
      @params['secret'] = secret || config.api_secret
      @country = country || config.default_country
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
      @request_uri = "/api/#{country}/address/cleanse?#{encoded_params}"
    end

    def execute_request
      request = Net::HTTP::Get.new(request_uri)

      response = http.request(request)

      self.response_body = response.body
      self.response_status = response.code
    end

    def build_result
      if response_status != '200'
        raise AddressFinder::RequestRejectedError.new(@response_status, @response_body)
      end

      if response_hash['matched']
        self.result = Result.new(response_hash['address'] || response_hash)
      else
        self.result = nil
      end
    end

    def encoded_params
      query_params = params.map do |k,v|
        "#{k}=#{ERB::Util.url_encode(v)}"
      end

      query_params.join('&')
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
