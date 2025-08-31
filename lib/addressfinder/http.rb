require 'net/http'

module AddressFinder
  class HTTP
    attr_reader :config

    def initialize(config)
      @config = config
      @connection_is_bad = false
    end

    def start(&block)
      net_http.start do
        block.call(self)
      end
    end

    def request(request_uri)
      retries = 0
      begin
        re_establish_connection if @connection_is_bad

        uri = build_uri(request_uri)
        request = Net::HTTP::Get.new(uri)

        net_http.request(request)
      rescue Net::ReadTimeout, Net::OpenTimeout, SocketError => error
        if retries < config.retries
          retries += 1
          sleep(config.retry_delay)
          @connection_is_bad = true if net_http.started?
          retry
        else
          raise error
        end
      end
    end

    private

    def re_establish_connection
      @connection_is_bad = false
      net_http.finish
      net_http.start
    end

    def build_uri(request_uri)
      uri = URI(request_uri)
      encoded_ca = URI.encode_www_form_component(config.ca)

      if uri.query
        uri.query += "&ca=#{encoded_ca}"
      else
        uri.query = "ca=#{encoded_ca}"
      end

      uri.to_s
    end

    def net_http
      @net_http ||= begin
        http = Net::HTTP.new(config.hostname, config.port, config.proxy_host,
                             config.proxy_port, config.proxy_user,
                             config.proxy_password)
        http.open_timeout = config.timeout
        http.read_timeout = config.timeout
        http.use_ssl = config.port == 443
        http
      end
    end
  end
end
