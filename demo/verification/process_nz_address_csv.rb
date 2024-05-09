require "addressfinder"
require "csv"

AddressFinder.configure do |af|
  af.api_key = ENV["AF_KEY"]
  af.api_secret = ENV["AF_SECRET"]
end

def syntax_check
  warn "Syntax: bundle exec ruby address_verification_nz_batch.rb <input_file.csv>" unless ARGV.size == 1

  return false unless ARGV.size == 1

  # confirm expected environment variables set
  if ENV["AF_KEY"].nil? || ENV["AF_SECRET"].nil?
    warn "API key and/or secret not set. Please set AF_KEY and AF_SECRET environment variables."
    return false
  end

  true
end

def process_csv
  filename = ARGV[0]
  block_size = 20
  block = []

  puts CSV.generate_line(%w[address_id address_query
    address_query_length full_address address_id])

  CSV.foreach(filename, headers: true) do |row|
    block << row
    if block.size == block_size
      process_block(block)
      block = [] # Reset the block for the next set of lines
    end
  end

  # Process the last block if it contains any lines
  process_block(block) unless block.empty?
end

# Processes a block of CSV rows
def process_block(block)
  addresses = block.collect { |row| row["address_query"] }

  results = AddressFinder.address_verification_nz_batch(addresses: addresses, concurrency: 5)

  results.each_with_index do |result, index|
    row = block[index]

    line = [row["address_id"], row["address_query"],
      row["address_query_length"]]

    if result
      line << (result.a)
      line << (result.pxid)
    else
      line << ""
      line << ""
    end

    puts CSV.generate_line(line)
  end
end

if syntax_check
  process_csv
end
