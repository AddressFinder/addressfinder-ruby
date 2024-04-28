module AddressFinder
  module V1
    module Email
      class BatchVerification
        attr_reader :emails, :http, :args, :results

        # Verifies an array of email addresses using concurrency to reduce the execution time.
        # The results of the verification are stored in the `results` attribute, in the same order
        # in which they were supplied.
        #
        # @param [Array<String>] emails
        # @param [AddressFinder::V1::Http] http
        # @param [Hash] args
        def initialize(emails:, **args)
          @emails = emails
          @args = args

          if args[:concurrency]
            if args[:concurrency].to_i > 10
              warn "WARNING: Concurrency level of #{args[:concurrency]} is higher than the maximum of 10. Using 10."
              @concurrency_level = 10
            else
              @concurrency_level = args[:concurrency].to_i
            end
          end
        end

        def perform
          verify_each_email_concurrently

          self
        end

        private

        def verify_each_email_concurrently
          thread_pool = []
          @results = Array.new(emails.length)

          @emails.each_with_index do |email, index_of_email|
            # Start a new thread for each task
            thread_pool << Thread.new { verify_email(email, index_of_email) }

            # If we've reached max threads, wait for one to finish before starting another
            if thread_pool.size >= @concurrency_level
              thread = thread_pool.shift
              thread.join
            end
          end

          # Wait for all threads to complete
          thread_pool.each(&:join)
        end

        # Verifies a block of email addresses, and writes the results into @verification_results
        def verify_email(email, index_of_email)
          @results[index_of_email] = AddressFinder.email_verification(email: email)

          $stderr.putc "."
        rescue AddressFinder::RequestRejectedError => e
          @results[index_of_email] = OpenStruct.new(success: false, body: e.body, status: e.status)
          $stderr.putc "x"
        end
      end
    end
  end
end
