require "spec_helper"
require "cgi"

RSpec.describe AddressFinder::V2::Au::BatchVerification do
  let(:http) {
    AddressFinder::HTTP.new(AddressFinder.configuration)
  }

  before do
    AddressFinder.configure do |af|
      af.api_key = "XXX"
      af.api_secret = "YYY"
      af.timeout = 5
      af.retries = 3
    end

    api_url_to_stub = "https://api.addressfinder.io/api/au/address/v2/verification"
    stub_request(:get, /#{api_url_to_stub}/)
      .to_return do |request|
      uri = URI.parse(request.uri)
      params = CGI.parse(uri.query)
      address_query = params["q"].first

      # returns a JSON string with the requested address embedded
      {
        body: verified_response(address_query), status: 200
      }
    end
  end

  describe "when operating concurrently" do
    subject(:results) do
      AddressFinder::V2::Au::BatchVerification.new(addresses: [
        "10/274 harbour drive, coffs harbour NSW 2450",
        "49 CORNISH ST, COBAR NSW 2835",
        "1 TANCRED DR , BOURKE NSW 2840"
      ], concurrency: 2, http: http).perform.results
    end

    it "has 3 results" do
      expect(results.size).to eq(3)
    end

    it "contains the results in the expected order" do
      expect(results.collect(&:full_address)).to eq([
        "10/274 harbour drive, coffs harbour NSW 2450", "49 CORNISH ST, COBAR NSW 2835", "1 TANCRED DR , BOURKE NSW 2840"
      ])
    end

    it "returns records of type Result" do
      expect(results.collect(&:class).uniq).to eq([AddressFinder::V2::Au::Verification::Result])
    end
  end

  describe "with an excessive concurrency level" do
    it "writes a warning message" do
      verifier = AddressFinder::V2::Au::BatchVerification.new(addresses: ["address1", "address2"], concurrency: 100, http: http)
      expect(verifier).to receive(:warn).with("WARNING: Concurrency level of 100 is higher than the maximum of 5. Using 5.")
      verifier.perform
    end
  end

  def verified_response(address)
    %({
      "matched": true,
      "success": true,
      "address": {
        "id": "8910ed1a-82ab-6d89-a9cc-60d18c7edaad",
        "full_address": "#{address}",
        "address_line_1": "30 Hoipo Road",
        "address_line_2": null,
        "address_line_combined": "30 Hoipo Road",
        "locality_name": "SOMERSBY",
        "state_territory": "NSW",
        "postcode": "2250",
        "latitude": null,
        "longitude": null,
        "box_identifier": null,
        "box_type": null,
        "street_number_1": "30",
        "street_number_2": null,
        "unit_identifier": null,
        "unit_type": null,
        "level_number": null,
        "level_type": null,
        "lot_identifier": "1",
        "site_name": null,
        "street_name": "Hoipo",
        "street_type": "Road",
        "street_suffix": null,
        "street": "Hoipo Road",
        "meshblock": null,
        "sa1_id": null,
        "sa2_id": null,
        "lga_name": null,
        "lga_type_code": null,
        "gnaf_id": null,
        "legal_parcel_id": null,
        "supplementary": "",
        "parcel_locker_type": null,
        "parcel_locker_identifier": null
      }
    })
  end
end
