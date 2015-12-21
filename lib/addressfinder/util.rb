module AddressFinder
  class Util

    def self.encode(v)
      CGI::escape(v.to_s)
    end

    def self.encode_and_join_params(params)
      params.map{ |k,v| "#{k}=#{encode(v)}" }.join('&')
    end
  end
end
