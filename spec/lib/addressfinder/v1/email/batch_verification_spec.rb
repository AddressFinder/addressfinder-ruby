require "spec_helper"

RSpec.describe AddressFinder::V1::Email::BatchVerification, focus: true do
  let(:http){
    AddressFinder::HTTP.new(AddressFinder.configuration) 
  }

  before do 
    AddressFinder.configure do |af|
      af.api_key = "XXX"
      af.api_secret = "YYY"
      af.timeout = 5
      af.retries = 3
    end
  
    stub_request(:get, /\Ahttps:\/\/api\.addressfinder\.io\/api\/email\/v1\/verification/).
    to_return do |request| 
      uri = URI.parse(request.uri)
      params = CGI.parse(uri.query)
      email = params["email"].first

      # returns a JSON string with the requested email address included
      {
        body: verified_response(email), status: 200
      } 
    end
  end

  describe "when operating concurrently" do 
    subject(:results) do 
      AddressFinder::V1::Email::BatchVerification.new(emails: ["bert@myemail.com", "charlish@myemail.com", "bademailaddress"], http: http).perform.results
    end

    it "has 3 results" do 
      expect(results.size).to eq(3)
    end

    it "contains the results in the expected order" do 
      expect(results.collect(&:verified_email)).to eq(["bert@myemail.com", "charlish@myemail.com", "bademailaddress"])
    end

    it "returns records of type Result" do 
      expect(results.collect(&:class).uniq).to eq([AddressFinder::V1::Base::Result])
    end
  end

  describe "with an excessive concurrency level" do 
    it "writes a warning message" do 
      verifier = AddressFinder::V1::Email::BatchVerification.new(emails: ["bert@myemail.com", "charlish@myemail.com", "bademailaddress"], concurrency: 100, http: http)
      expect(verifier).to receive(:warn).with("WARNING: Concurrency level of 100 is higher than the maximum of 20. Using 20.")
      verifier.perform
    end
  end

  def verified_response(email)
    %Q[{
      "verified_email": "#{email}",
      "email_account": "ignored_account",
      "email_domain": "ignored.domain",
      "is_verified": true,
      "is_disposable": false,
      "is_role": false,
      "is_public": false,
      "is_catch_all": false,
      "not_verified_reason": null,
      "not_verified_code": null,
      "success": true
    }]
  end
end