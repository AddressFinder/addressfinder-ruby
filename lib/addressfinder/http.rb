require 'net/http'

module AddressFinder
  class HTTP
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def start(&block)
      net_http.start do
        block.call(self)
      end
    end

    def request(args)
      retries = 0
      begin
        net_http.request(args)
      rescue Net::ReadTimeout, Net::OpenTimeout => error
        if retries < config.retries
          retries += 1
          sleep(1)
          if net_http.started?
            net_http.finish
            net_http.start
          end
          retry
        else
          raise error
        end
      end
    end

    private

    def net_http
      @net_http ||= begin
        http = Net::HTTP.new(config.hostname, config.port, config.proxy_host,
                             config.proxy_port, config.proxy_user,
                             config.proxy_password)
        http.open_timeout = config.timeout
        http.read_timeout = config.timeout
        http.use_ssl = true
        http
      end
    end
  end
end