module AddressFinder
  class Bulk
    def initialize(http:, verification_version:, default_country:, &block)
      @block = block
      @verification_version = verification_version
      @default_country = default_country
      @http_config = http
    end

    def perform
      http_config.start do |http|
        block.call ClientProxy.new(http: http, verification_version: verification_version, default_country: default_country)
      end
    end

    private

    attr_reader :block, :verification_version, :default_country, :http_config

    class ClientProxy
      def initialize(http:, verification_version:, default_country:)
        @verification_version = verification_version
        @default_country = default_country
        @http = http
      end

      def cleanse(args={})
        AddressFinder::Verification.new(**args.merge(http: http)).perform.result
      end

      def verification(args={})
        if verification_version&.downcase == "v2" && (args[:country] || default_country) == 'au'
          AddressFinder::V2::Au::Verification.new(**args.merge(http: http)).perform.result
        else
          AddressFinder::Verification.new(**args.merge(http: http)).perform.result
        end
      end

      def email_verification(args={})
        AddressFinder::Email::Verification.new(**args.merge(http: http)).perform.result
      end

      private

      attr_reader :http, :verification_version, :default_country
    end
  end
end
