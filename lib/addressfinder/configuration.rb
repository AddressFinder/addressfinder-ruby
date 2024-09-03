module AddressFinder
  class Configuration
    attr_accessor :api_key
    attr_accessor :api_secret
    attr_accessor :verification_version
    attr_accessor :hostname
    attr_accessor :port
    attr_accessor :proxy_host
    attr_accessor :proxy_port
    attr_accessor :proxy_user
    attr_accessor :proxy_password
    attr_accessor :timeout
    attr_accessor :default_country
    attr_accessor :domain
    attr_accessor :retries
    attr_accessor :retry_delay

    attr_reader :ca

    def initialize
      self.hostname = 'api.addressfinder.io'
      self.port = 443
      self.timeout = 10
      self.retries = 12
      self.retry_delay = 5
      self.default_country = 'nz'
      self.verification_version = 'v1'
      self.ca = "Ruby/#{AddressFinder::VERSION}"
    end

    private

    def ca=(value)
      @ca = value
    end
  end
end
