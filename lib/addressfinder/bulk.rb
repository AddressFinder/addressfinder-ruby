module AddressFinder
  class Bulk
    def initialize(http:, verification_version:, &block)
      @block = block
      @verification_version = verification_version
      @http_config = http
    end

    def perform
      http_config.start do |http|
        block.call ClientProxy.new(http: http, verification_version: verification_version)
      end
    end

    private

    attr_reader :block, :verification_version, :http_config

    class ClientProxy
      def initialize(http:, verification_version:)
        @verification_version = verification_version
        @http = http
      end

      def cleanse(args={})
        AddressFinder::Verification.new(args.merge(http: http)).perform.result
      end

      def verification(args={})
      if verification_version&.downcase == "v2"
          AddressFinder::V2::Au::Verification.new(args.merge(http: http)).perform.result
        else
          AddressFinder::Verification.new(args.merge(http: http)).perform.result
        end
      end

      private

      attr_reader :http, :verification_version
    end
  end
end
