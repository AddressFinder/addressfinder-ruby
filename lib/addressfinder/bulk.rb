module AddressFinder
  class Bulk
    def initialize(http:, &block)
      @block = block
      @http_config = http
    end

    def perform
      http_config.start do |http|
        block.call ClientProxy.new(http: http)
      end
    end

    private

    attr_reader :block, :http_config

    class ClientProxy
      def initialize(http:)
        @http = http
      end

      def cleanse(args={})
        AddressFinder::Cleanse.new(args.merge(http: http)).perform.result
      end

      private

      attr_reader :http
    end
  end
end
