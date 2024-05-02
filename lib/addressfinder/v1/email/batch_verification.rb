module AddressFinder
  module V1
    module Email
      class BatchVerification
        attr_reader :emails, :results

        # Verifies an array of email addresses using concurrency to reduce the execution time.
        # The results of the verification are stored in the `results` attribute, in the same order
        # in which they were supplied.
        #
        # @param [Array<String>] emails
        # @param [Hash] args
        def initialize(emails:, http:, concurrency: 5, **args)
          @emails = emails
          @concurrency = concurrency
          @http = http
          @args = args
        end

        def perform
          confirm_concurrency_level
          verify_each_email_concurrently

          self
        end

        private

        attr_reader :args, :concurrency, :http

        MAX_CONCURRENCY_LEVEL = 10

        def confirm_concurrency_level
          if @concurrency > MAX_CONCURRENCY_LEVEL
            warn "WARNING: Concurrency level of #{@concurrency} is higher than the maximum of #{MAX_CONCURRENCY_LEVEL}. Using #{MAX_CONCURRENCY_LEVEL}."
            @concurrency = MAX_CONCURRENCY_LEVEL
          end
        end

        def verify_each_email_concurrently
          @results = Concurrent::Array.new(emails.length)

          pool = Concurrent::FixedThreadPool.new(concurrency)

          @emails.each_with_index do |email, index_of_email|
            # Start a new thread for each task
            pool.post do
              verify_email(email, index_of_email)
            end
          end

          ## Shutdown the pool and wait for all tasks to complete
          pool.shutdown
          pool.wait_for_termination
        end

        # Verifies a block of email addresses, and writes the results into @verification_results
        def verify_email(email, index_of_email)
          @results[index_of_email] = AddressFinder::V1::Email::Verification.new(email: email, http: http.clone, **args).perform.result
        rescue AddressFinder::RequestRejectedError => e
          @results[index_of_email] = OpenStruct.new(success: false, body: e.body, status: e.status)
        end
      end
    end
  end
end
