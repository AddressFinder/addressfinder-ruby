# Addressfinder Ruby Gem

[![Gem Version](https://badge.fury.io/rb/addressfinder.svg)](http://badge.fury.io/rb/addressfinder)
[![Build  Status](https://travis-ci.com/github/AddressFinder/addressfinder-ruby.svg)](https://travis-ci.com/github/AddressFinder/addressfinder-ruby)

A client library for accessing the [Addressfinder](https://addressfinder.nz/?utm_source=github&utm_medium=readme&utm_campaign=addressfinder_rubygem&utm_term=AddressFinder) APIs.

## Installation

Add this line to your application's Gemfile:

    gem 'addressfinder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install addressfinder

## Configuration

Use the configure block to set your `api_key` and `api_secret`.

```ruby
AddressFinder.configure do |af|
  # Required
  af.api_key = 'XXXXXXXXXX'
  af.api_secret = 'YYYYYYYYYY'

  # Optional
  af.default_country = 'nz' # default: nz
  af.verification_version = 'v2' # default: v1
  af.timeout = 10 # default: 10 seconds
  af.retries = 12 # default: 12
  af.retry_delay = 5 # default: 5 seconds
  af.domain = 'yourdomain.com'
  af.proxy_host = 'yourproxy.com'
  af.proxy_port = 8080
  af.proxy_user = 'username'
  af.proxy_password = 'password'
end
```

**_Don't know your key and secret?_**
*Login to the [Addressfinder portal](https://portal.addressfinder.io/?utm_source=github&utm_medium=readme&utm_campaign=addressfinder_rubygem&utm_term=AddressFinder%20Portal) to obtain your key and secret.*

**_For Ruby on Rails:_**
*The configure block is best placed in an initializer file (`./config/initializers/addressfinder.rb`).*

## Usage

For available parameters and example responses, see the API documentation pages for [New Zealand](https://addressfinder.nz/docs?utm_source=github&utm_medium=readme&utm_campaign=addressfinder_rubygem&utm_term=New%20Zealand) or [Australia](https://addressfinder.com.au/docs?utm_source=github&utm_medium=readme&utm_campaign=addressfinder_rubygem&utm_term=Australia).


#### Address Verification

To verify a single New Zealand address, use the following method:

```ruby
result = AddressFinder.address_verification(q: '186 Willis St, Wellington', country: 'nz')

if result
  $stdout.puts "Success: #{result.postal}"
else
  $stdout.puts "Sorry, can't find that address"
end
```

You can also verify a batch of New Zealand addresses using the following method. 
We suggest that you send up to 100 addresses in each batch. 

```ruby
result = AddressFinder.address_verification_batch(addresses: [
  "186 Willis St, Wellington", 
  "1 Ghuznee St, Te Aro, Wellington 6011"
], country: "nz", concurrency: 5)

if result
  $stdout.puts "Success: #{result.postal}"
else
  $stdout.puts "Sorry, can't find that address"
end
```

To verify a single Australian address, use the following method:

```ruby
result = AddressFinder.address_verification(q: '10/274 Harbour Drive, Coffs Harbour NSW 2450', country: 'au')

if result
  $stdout.puts "Success: #{result.postal}"
else
  $stdout.puts "Sorry, can't find that address"
end
```

You can also verify a batch of New Zealand addresses using the following method:
We suggest that you send up to 100 addresses in each batch. 

```ruby
result = AddressFinder.address_verification_batch(addresses: [
  "186 Willis St, Wellington",
  "1 Ghuznee St, Te Aro, Wellington 6011"
], country: 'nz', concurrency: 5)

if result
  $stdout.puts "Success: #{result.postal}"
else
  $stdout.puts "Sorry, can't find that address"
end
```

#### Address Search

The Address Search API supports the following address sets:

* New Zealand addresses
* Australian addresses from the GNAF dataset only

```ruby
begin
  results = AddressFinder.address_search(q: '186 Willis Street')
  if results.any?
    $stdout.puts "Success: #{results}"
  else
    $stdout.puts "Sorry, there were no address matches"
  end
rescue AddressFinder::RequestRejectedError => e
  response = JSON.parse(e.body)
  $stdout.puts response['message']
end
```

#### Address Autocomplete

The Address Autocomplete API supports the following address sets:

* Australian addresses from the GNAF and PAF datasets only

```ruby
begin
  results = AddressFinder.address_autocomplete(q: '275 high st, bel', au_paf: '1')
  if results.any?
    $stdout.puts "Success: #{results}"
  else
    $stdout.puts "Sorry, there were no address matches"
  end
rescue AddressFinder::RequestRejectedError => e
  response = JSON.parse(e.body)
  $stdout.puts response['message']
end
```

#### Address Metadata

```ruby
begin
  result = AddressFinder.address_info(pxid: '1-.B.3l')
  if result
    $stdout.puts "Success: #{result.a}"
  else
    $stdout.puts "Sorry, can't find that address"
  end
rescue AddressFinder::RequestRejectedError => e
  response = JSON.parse(e.body)
  $stdout.puts response['message']
end
```

#### Location Autocomplete

```ruby
begin
  results = AddressFinder.location_search(q: 'Queen Street')
  if results.any?
    $stdout.puts "Success: #{results}"
  else
    $stdout.puts "Sorry, there were no location matches"
  end
rescue AddressFinder::RequestRejectedError => e
  response = JSON.parse(e.body)
  $stdout.puts response['message']
end
```

#### Location Metadata

```ruby
begin
  result = AddressFinder.location_info(pxid: '1-.B.3l')
  if result
    $stdout.puts "Success: #{result.a}"
  else
    $stdout.puts "Sorry, can't find that location"
  end
rescue AddressFinder::RequestRejectedError => e
  response = JSON.parse(e.body)
  $stdout.puts response['message']
end
```

#### Email Verification

This example shows how to request verification of a single email address. 

```ruby
begin
  result = AddressFinder.email_verification(email: 'john.doe', features: "domain,connection")
  $stdout.puts "This email address is verified: #{result.is_verified}"
rescue AddressFinder::RequestRejectedError => e
  response = JSON.parse(e.body)
  $stdout.puts response['message']
end
```

This example shows how to request verification of several email addresses:

```ruby 
emails = [
  "bert@myemail.com", 
  "charlish@myemail.com", 
  "support@addressfinder.com", 
  "bad-email-address"
]

results = AddressFinder.email_verification_batch(emails: emails, concurrency: 2, features: "provider,domain,connection")

results.each_with_index do |result, index|
  puts "Email: #{emails[index]} - #{result.is_verified ? "Verified" : "Unverified"}"
end
```

The emails will be verified concurrently, and returned in the same order in 
which they were provided.

#### Phone Verification

```ruby
begin
  result = AddressFinder.phone_verification(phone_number: '1800 152 363', default_country_code: 'AU')
  $stdout.puts "This phone number is verified: #{result.is_verified}"
rescue AddressFinder::RequestRejectedError => e
  response = JSON.parse(e.body)
  $stdout.puts response['message']
end
```

## Advanced Usage

#### Bulk Operations

If you have a series of API requests, you can use the
bulk method to re-use the HTTP connection.

**Note:** The bulk method is currently only available for Address Verification, Email Verification and Phone Verification (`#verification`, `#email_verification`, `#phone_verifiction`).

```ruby
AddressFinder.bulk do |af|
  CSV.foreach('auckland_addresses.csv') do |row|
    result = af.verification(q: row[0], region_code: '1')

    if result
      $stdout.puts "Success: #{result.postal}"
    else
      $stdout.puts "Sorry, can't find that address"
    end
  end
end
```


#### Key and Secret override

What if you want to use another account for a specific query? You can override the `api_key` and `api_secret`.

```ruby
begin
  result = AddressFinder.address_info(pxid: '1-.B.3l', key: 'AAAAAAAAAAAAA', secret: 'BBBBBBBBBBBBB')
  if result
    $stdout.puts "Success: #{result.a}"
  else
    $stdout.puts "Sorry, can't find that address"
  end
rescue AddressFinder::RequestRejectedError => e
  response = JSON.parse(e.body)
  $stdout.puts response['message']
end
```

### Testing

You can run all the specs with the following command:

`docker-compose up`

You can `guard` for repeating test runs (while editing new code):

`docker-compose run ruby bundle exec guard`
