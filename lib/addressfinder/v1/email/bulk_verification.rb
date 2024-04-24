module AddressFinder
  module V1
    module Email
      class BulkVerification
        attr_reader :emails, :http, :args, :results

        def initialize(emails:, http:, **args)
          @emails = emails
          @http = http
          @args = args

          @block_size = 10
          @concurrency_level = 5
        end

        def perform
          slice_supplied_emails_into_blocks
          verify_each_block_concurrently
          assemble_results

          self
        end

        private

        def slice_supplied_emails_into_blocks
          @email_blocks = emails.each_slice(@block_size).to_a
          @email_block_results = Array.new(@email_blocks.size)
        end

        def verify_each_block_concurrently
          # Create a thread pool
          thread_pool = []

          @email_blocks.each do |block_emails, index_of_block|
            puts "Block emails: #{block_emails.inspect}"

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

        def verify_block(block_emails, index_of_block)
          block_emails.each do |email|
            puts "verifying email: #{email}"
            sleep(1)
          end

          @email_block_results[index_of_block] = []
        end

        def verify_email(email, http, args)
          puts "Verifying: #{email}"
          sleep(1)
        end

        def assemble_results
          @results = @email_block_results.flatten
        end
      end
    end
  end
end
