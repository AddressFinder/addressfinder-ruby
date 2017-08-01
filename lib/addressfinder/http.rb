require 'net/http'

module AddressFinder
  class HTTP
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def request(args)
      retries = 0
      begin
        net_http.request(args)
      rescue Net::ReadTimeout, Net::OpenTimeout => error
        if retries < config.retries
          retries += 1
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