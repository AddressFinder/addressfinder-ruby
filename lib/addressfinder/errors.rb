module AddressFinder
  class RequestRejectedError < StandardError

    attr_reader :status, :body

    def initialize(status, body)
      @status = status
      @body = body

      super("Request rejected with status code: #{status}\n#{body}")
    end
  end
end
