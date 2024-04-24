module AddressFinder
  module V1
    module Email
      class BulkVerification
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

          @block_size = 1
          @concurrency_level = 5
        end

        def perform
          slice_supplied_emails_into_blocks
          verify_each_block_concurrently
          assemble_results

          self
        end

        private

        # Slices the supplied emails into blocks of size `@block_size`
        def slice_supplied_emails_into_blocks
          @email_blocks = emails.each_slice(@block_size).to_a

          # Holds the results from each of the threads that process a block of emails.
          # There are a matching number of 'slots' for each email block
          @verification_results = Array.new(@email_blocks.size)
        end

        def verify_each_block_concurrently
          thread_pool = []

          @email_blocks.each_with_index do |block_emails, index_of_block|
            # Start a new thread for each task
            thread_pool << Thread.new { verify_block(block_emails, index_of_block) }

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
        def verify_block(block_emails, index_of_block)
          AddressFinder.bulk do |af|
            block_results = []

            block_emails.each do |email|
              block_results << af.email_verification(email: email)
              $stderr.putc "."
            end

            @verification_results[index_of_block] = block_results
          end
        end

        def assemble_results
          @results = @verification_results.flatten
        end
      end
    end
  end
end
