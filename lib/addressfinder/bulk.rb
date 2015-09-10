module AddressFinder
  class Bulk
    def initialize(&block)
      @block = block
    end

    def perform
      Net::HTTP.start(config.hostname, config.port, use_ssl: true,
                                                    open_timeout: config.timeout,
                                                    read_timeout: config.timeout) do |http|
        block.call ClientProxy.new(http: http)
      end
    end

    private

    attr_reader :block

    def config
      @_config ||= AddressFinder.configuration
    end

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
