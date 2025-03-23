module AddressFinder
  module V1
    module Nz
      class BatchVerification
        attr_reader :addresses, :results

        # Verifies an array of addresses using concurrency to reduce the execution time.
        #
        # The results of the verification are stored in the `results` attribute, in the same order
        # in which they were supplied.
        #
        # @param [Array<String>] addresses array of address query strings
        # @param [AddressFinder::HTTP] http HTTP connection helper
        # @param [Integer] concurrency How many threads to use for verification
        # @param [Hash] args Any additional arguments that will be passed onto the Address Verification API
        def initialize(addresses:, http: nil, concurrency: 2, **args)
          @addresses = addresses
          @concurrency = concurrency
          @http = http
          @args = args
        end

        def perform
          confirm_concurrency_level
          verify_each_address_concurrently

          self
        end

        private

        attr_reader :args, :concurrency, :http

        MAX_CONCURRENCY_LEVEL = 5

        def confirm_concurrency_level
          return unless @concurrency > MAX_CONCURRENCY_LEVEL

          warn "WARNING: Concurrency level of #{@concurrency} is higher than the maximum of #{MAX_CONCURRENCY_LEVEL}. Using #{MAX_CONCURRENCY_LEVEL}."
          @concurrency = MAX_CONCURRENCY_LEVEL
        end

        def verify_each_address_concurrently
          @results = Concurrent::Array.new(addresses.length)

          pool = Concurrent::FixedThreadPool.new(concurrency)

          addresses.each_with_index do |address, index_of_address|
            # Start a new thread for each task
            pool.post do
              @results[index_of_address] = verify_address(address)
            end
          end

          ## Shutdown the pool and wait for all tasks to complete
          pool.shutdown
          pool.wait_for_termination
        end

        # Verifies a single address, and writes the result into @results
        def verify_address(address)
          return if address.empty?

          AddressFinder::Verification.new(q: address, http: http.clone, **args).perform.result || false
        rescue AddressFinder::RequestRejectedError => e
          OpenStruct.new(success: false, body: e.body, status: e.status)
        end
      end
    end
  end
end
