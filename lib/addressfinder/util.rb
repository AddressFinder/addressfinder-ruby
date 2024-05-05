require "cgi"

module AddressFinder
  class Util
    def self.encode(v)
      CGI.escape(v.to_s)
    end

    def self.encode_and_join_params(params)
      # URI.encode_www_form(params)
      params.map do |k, v|
        if v.is_a? Array
          v.collect { |e| "#{k}[]=#{encode(e)}" }
        else
          "#{k}=#{encode(v)}"
        end
      end.join("&")
    end
  end
end
