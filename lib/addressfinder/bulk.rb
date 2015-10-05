module AddressFinder
  class Bulk
    def initialize(http_config:,  &block)
      @block = block
      @http_config = http_config
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
        AddressFinder::Cleanse.new(args.merge(http: http)).perform
      end

      private

      attr_reader :http
    end
  end
end
