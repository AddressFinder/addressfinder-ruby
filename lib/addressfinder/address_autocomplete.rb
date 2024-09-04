require 'ostruct'

module AddressFinder
  class AddressAutocomplete

    attr_reader :results

    def initialize(params:, http:)
      @http = http
      @country = params.delete(:country) || 'au'

      @params = params
      @params[:key] ||= config.api_key
      @params[:secret] ||= config.api_secret
    end

    def perform
      validate_params
      build_request
      execute_request
      build_result

      self
    end

    private

    attr_reader :request_uri, :params, :country, :http
    attr_accessor :response_body, :response_status
    attr_writer :results

    def validate_params
      if country != 'au'
        raise AddressFinder::RequestRejectedError.new("400", "#address_autocomplete only available for Australian addresses")
      end
    end

    def build_request
      @request_uri = "/api/au/address/autocomplete.json?#{encoded_params}"
    end

    def encoded_params
      Util.encode_and_join_params(params)
    end

    def execute_request
      response = http.request(request_uri)

      self.response_body = response.body
      self.response_status = response.code
    end

    def build_result
      case response_status
      when '200'
        self.results = response_hash['completions'].map do |result_hash|
          Result.new(result_hash)
        end
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
