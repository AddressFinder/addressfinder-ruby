# AddressFinder Ruby Gem

A client library for accessing the AddressFinder APIs.

## Installation

Add this line to your application's Gemfile:

    gem 'addressfinder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install addressfinder

## Usage

### Configuration

You should call the configure block on startup of your app. In a Ruby on Rails application this
is normally performed in an initializer file. For example `./config/initializers/addressfinder.rb`

    AddressFinder.configure do |af|
      # Mandatory configuration
      af.api_key = 'XXXXXXXXXX'
      af.api_secret = 'YYYYYYYYYY'
      af.default_country = 'nz'

      # Optional configuration
      af.timeout = 10 # seconds
      af.proxy_host = 'corp.proxy.com'
      af.proxy_port = 8080
      af.proxy_user = 'username'
      af.proxy_password = 'password'
    end

You can obtain your API key and secret from the AddressFinder Portal.

### Address Cleansing

See the documentation on the available parameters and expected response here:

https://addressfinder.nz/docs/address_cleanse_api/

Usage example:

    result = AddressFinder.cleanse(q: '186 Willis St, Wellington')

    if result
      $stdout.puts "Success: #{result.postal}""
    else
      $stdout.puts "Sorry, can't find that address"
    end

### Bulk Operations

If you have a series of calls you need to make to AddressFinder, you can use the
bulk method which re-uses the HTTP connection.

Usage example:

    AddressFinder.bulk do |af|
      CSV.foreach('auckland_addresses.csv') do |row|
        result = af.cleanse(q: row[0], region_code: '1')

        if result
          $stdout.puts "Success: #{result.postal}""
        else
          $stdout.puts "Sorry, can't find that address"
        end
      end
    end
