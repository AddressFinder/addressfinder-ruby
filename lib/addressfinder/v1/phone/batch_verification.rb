module AddressFinder
  module V1
    module Phone
      class BatchVerification
        attr_reader :phone_numbers, :results

        # Verifies an array of phone numbers using concurrency to reduce the execution time.
        # The results of the verification are stored in the `results` attribute, in the same order
        # in which they were supplied.
        #
        # @param [Array<String>] phone_numbers
        # @param [String] default_country_code
        # @param [AddressFinder::HTTP] http HTTP connection helper
        # @param [Integer] concurrency How many threads to use for verification
        # @param [Hash] args Any additional arguments that will be passed onto the EV API
        def initialize(phone_numbers:, default_country_code:, http:, concurrency: 5, **args)
          @phone_numbers = phone_numbers
          @concurrency = concurrency
          @default_country_code = default_country_code
          @http = http
          @args = args
        end

        def perform
          confirm_concurrency_level
          verify_each_phone_number_concurrently

          self
        end

        private

        attr_reader :args, :concurrency, :http, :default_country_code

        MAX_CONCURRENCY_LEVEL = 10

        def confirm_concurrency_level
          return unless @concurrency > MAX_CONCURRENCY_LEVEL

          warn "WARNING: Concurrency level of #{@concurrency} is higher than the maximum of #{MAX_CONCURRENCY_LEVEL}. Using #{MAX_CONCURRENCY_LEVEL}."
          @concurrency = MAX_CONCURRENCY_LEVEL
        end

        def verify_each_phone_number_concurrently
          @results = Concurrent::Array.new(phone_numbers.length)

          pool = Concurrent::FixedThreadPool.new(concurrency)

          @phone_numbers.each_with_index do |phone_number, index_of_phone_number|
            # Start a new thread for each task
            pool.post do
              @results[index_of_phone_number] = verify_phone_number(phone_number)
            end
          end

          ## Shutdown the pool and wait for all tasks to complete
          pool.shutdown
          pool.wait_for_termination
        end

        # Verifies a single phone number, and writes the result into @results
        def verify_phone_number(phone_number)
          return if phone_number.empty?

          AddressFinder::V1::Phone::Verification.new(phone_number: phone_number, default_country_code: default_country_code, http: http.clone, **args).perform.result
        rescue AddressFinder::RequestRejectedError => e
          OpenStruct.new(success: false, body: e.body, status: e.status)
        end
      end
    end
  end
end
