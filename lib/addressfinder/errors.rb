module AddressFinder
  class RequestRejectedError < StandardError

    attr_reader :status, :body

    def initialize(status, body)
      @status = status
      @body = body

      super("Request rejected with status code: #{status}\n#{body}")
    end
  end

  class NotFoundError < StandardError

    attr_reader :status, :body, :pxid

    def initialize(status, body, pxid)
      @status = status
      @body = body
      @pxid = pxid

      super("The address or location you have requested could not be found.\n#{body}")
    end
  end
end
