# Addressfinder 1.15.0 (March 2025) #

* Automatically skip empty strings within Bulk verification

# Addressfinder 1.14.0 (February 2025) #

* Add support for Ruby 3.4

# Addressfinder 1.13.0 (September 2024) #

* Add client agent versioning

# Addressfinder 1.12.0 (May 2024) #

* Add a batch capability with concurrency for Address Verification
* Include a demo that shows address verification of a CSV file

# Addressfinder 1.11.0 (May 2024) #

* Add a batch capability with concurrency for Email Verification
* Increase minimum version of Ruby to version 2.7

# Addressfinder 1.10.0 (August 2023) #

* Add support for Email Verification
* Add support for Phone Verification
* Add support for Bulk Email Verification
* Add support for Bulk Phone Verification

# Addressfinder 1.9.1 (October 2022) #

* Add missing kwarg `**` for ruby 3

# Addressfinder 1.9.0 (July 2022) #

* Add support for Ruby 3.x
* Update gem dependencies

# Addressfinder 1.8.1 (October 2021) #

* Prevent NZ bulk and verification calls from using V2 module

# Addressfinder 1.8.0 (October 2021) #

* Create a V2 Module for verification (Australia)
* Remove PAF support from V1 verification API (Australia)
* Include API version number in configuration

# Addressfinder 1.7.1 (June 2, 2021) #

* Add support for PAF verification
* Rename cleanse to verification

# Addressfinder 1.7.0 (May 4, 2020) #

* Add support for Address Autocomplete API (Australia only)

# Addressfinder 1.6.2 (September 23, 2019) #

* Add support for an optional state_codes parameter in the Cleanse class

# Addressfinder 1.6.1 (January 14, 2019) #

* Add support for an optional census parameter in the Cleanse class

# Addressfinder 1.6.0 (August 10, 2017) #

* Add support for a configurable number of request retries

# Addressfinder 1.5.2 (December 21, 2015) #

* Update for the nested response format used in Address Cleanse Australia
* Add an encoding helper which uses CGI::escape

# Addressfinder 1.5.1 (November 25, 2015) #

* Update the ClientProxy #cleanse method to return result instead of an AddressFinder::Cleanse instance

# Addressfinder 1.5.0 (November 24, 2015) #

* Add support for supplying `key` and `secret` override values in each API call

# Addressfinder 1.4.0 (October 19, 2015) #

* Add support for Address Search API
* Add support for Address Info API

# Addressfinder 1.3.0 (October 16, 2015) #

* Add optional domain parameter to configuration and API calls

# Addressfinder 1.2.0 (October 1, 2015) #

* Add support for Location Search API
* Add support for Location Info API

# Addressfinder 1.1.2 (September 23, 2015) #

* Minor bugfixes

# Addressfinder 1.1.1 (September 14, 2015) #

* Minor bugfixes

# Addressfinder 1.1.0 (September 11, 2015) #

* Support for bulk operations

# Addressfinder 1.0.0 (September 10, 2015) #

* Support for address cleansing API
