require 'ostruct'

module AddressFinder
  module V1
    class Base
      attr_reader :result

      def initialize(params:, path:, http:)
        @params = params
        @params[:domain] ||= config.domain if (config.domain)
        @params[:key] ||= config.api_key
        @params[:secret] ||= config.api_secret
        @params[:format] ||= 'json'

        @path = path
        @http = http
      end

      def perform
        build_request
        execute_request
        build_result
  
        self
      end

      private
  
      attr_reader :request_uri, :params, :http, :path
      attr_accessor :response_body, :response_status
      attr_writer :result

      def build_request
        @request_uri = "#{path}?#{encoded_params}"
      end
  
      def encoded_params
        Util.encode_and_join_params(params)
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
        else
          raise AddressFinder::RequestRejectedError.new(response_status, response_body)
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
end