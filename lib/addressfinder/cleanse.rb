module AddressFinder
  class Cleanse
    def initialize(q:, country: nil, delivered: nil, post_box: nil, rural: nil, region_code: nil)
      @params = {}
      @params['q'] = q
      @params['delivered'] = delivered if delivered
      @params['post_box'] = post_box if post_box
      @params['rural'] = rural if rural
      @params['region_code'] = region_code if region_code
      @params['format'] = 'json'
      @params['key'] = config.api_key
      @params['secret'] = config.api_secret
      @country = country || config.default_country
    end

    def perform
      build_request
      execute_request
      build_result
    end

    private

    attr_reader :full_url, :params, :response_body, :response_status, :result, :country

    def build_request
      @full_url = "https://#{config.hostname}:#{config.port}/api/#{country}/address/cleanse?#{encoded_params}"
    end

    def execute_request
      uri = URI.parse(full_url)
      http = Net::HTTP.new(uri.host, uri.port, config.proxy_host, config.proxy_port, config.proxy_user, config.proxy_password)
      http.open_timeout = config.timeout
      http.read_timeout = config.timeout
      http.use_ssl = (uri.scheme == "https")

      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)

      @response_body = response.body
      @response_status = response.code
    end

    def build_result
      if response_status != '200'
        raise AddressFinder::RequestRejectedError.new(@response_status, @response_body)
      end

      if response_hash['matched']
        return Result.new(response_hash)
      end

      nil
    end

    def encoded_params
      query = params.map{|k,v| "#{k}=#{v}"}.join('&')
      URI::encode(query)
    end

    def response_hash
      @_response_hash ||= JSON.parse(response_body)
    end

    def config
      @_config ||= AddressFinder.configuration
    end

    class Result < OpenStruct
    end
  end
end
