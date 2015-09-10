module AddressFinder
  class Configuration
    attr_accessor :api_key
    attr_accessor :api_secret
    attr_accessor :hostname
    attr_accessor :port
    attr_accessor :proxy_host
    attr_accessor :proxy_port
    attr_accessor :proxy_user
    attr_accessor :proxy_password
    attr_accessor :timeout
    attr_accessor :default_country

    def initialize
      self.hostname = 'api.addressfinder.io'
      self.port = 443
      self.timeout = 10
    end
  end
end
