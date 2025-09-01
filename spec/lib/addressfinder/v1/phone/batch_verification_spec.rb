require "spec_helper"
require "cgi"

RSpec.describe AddressFinder::V1::Phone::BatchVerification do
  let(:http) {
    AddressFinder::HTTP.new(AddressFinder.configuration)
  }

  let(:phone_numbers) { ["0424980072", "02 9098 8273", "+61414421799"] }
  before do
    AddressFinder.configure do |af|
      af.api_key = "XXX"
      af.api_secret = "YYY"
      af.timeout = 5
      af.retries = 3
    end

    stub_request(:get, /\Ahttps:\/\/api\.addressfinder\.io\/api\/phone\/v1\/verification/)
      .to_return do |request|
      uri = URI.parse(request.uri)
      params = CGI.parse(uri.query)
      phone_number = params["phone_number"].first

      # returns a JSON string with the requested phone number embedded
      {
        body: verified_response(phone_number), status: 200
      }
    end
  end

  describe "when operating concurrently" do
    subject(:results) do
      AddressFinder::V1::Phone::BatchVerification.new(phone_numbers: phone_numbers, default_country_code: "AU", concurrency: 3, http: http).perform.results
    end

    it "has 3 results" do
      expect(results.size).to eq(3)
    end

    it "contains the results in the expected order" do
      expect(results.collect(&:raw_national)).to eq(phone_numbers)
    end

    it "returns records of type Result" do
      expect(results.collect(&:class).uniq).to eq([AddressFinder::V1::Base::Result])
    end
  end

  describe "with an excessive concurrency level" do
    it "writes a warning message" do
      verifier = AddressFinder::V1::Phone::BatchVerification.new(phone_numbers: phone_numbers, default_country_code: "AU", concurrency: 100, http: http)
      expect(verifier).to receive(:warn).with("WARNING: Concurrency level of 100 is higher than the maximum of 10. Using 10.")
      verifier.perform
    end
  end

  def verified_response(phone_number)
    %({
      "is_verified": true,
      "line_type": "mobile",
      "line_status": "connected",
      "line_status_reason": null,
      "country_code": "AU",
      "calling_code": "61",
      "raw_national": "#{phone_number}",
      "not_verified_code": null,
      "not_verified_reason": null,
      "success": true
    })
  end
end
