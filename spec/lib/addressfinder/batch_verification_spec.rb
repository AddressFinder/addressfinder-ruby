require "spec_helper"
require "cgi"

RSpec.describe AddressFinder::BatchVerification do
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

    api_url_to_stub = "https://api.addressfinder.io/api/nz/address/verification"
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
      AddressFinder::BatchVerification.new(addresses: [
        "1 ghuznee st te aro wellington 6011",
        "95 Opiki Road, Opiki 4474",
        "Level 2, 4 Bond Street, Te Aro, Wellington 6011"
      ], concurrency: 2, http: http).perform.results
    end

    it "has 3 results" do
      expect(results.size).to eq(3)
    end

    it "contains the results in the expected order" do
      expect(results.collect(&:a)).to eq([
        "1 ghuznee st te aro wellington 6011",
        "95 Opiki Road, Opiki 4474",
        "Level 2, 4 Bond Street, Te Aro, Wellington 6011"
      ])
    end

    it "returns records of type Result" do
      expect(results.collect(&:class).uniq).to eq([AddressFinder::Verification::Result])
    end
  end

  describe "with an excessive concurrency level" do
    it "writes a warning message" do
      verifier = AddressFinder::BatchVerification.new(addresses: ["address1", "address2"], concurrency: 100, http: http)
      expect(verifier).to receive(:warn).with("WARNING: Concurrency level of 100 is higher than the maximum of 5. Using 5.")
      verifier.perform
    end
  end

  def verified_response(address)
    %({
      "pxid": "2-.F.1W.p.0G1Js",
      "a": "#{address}",
      "postal": "#{address}",
      "aims_address_id": "1751263",
      "sufi": 1751263,
      "ta_id": "047",
      "ta": "Wellington City",
      "tasub_id": "04799",
      "tasub": "Area Outside Subdivision",
      "number": "186",
      "x": "174.7730294667",
      "y": "-41.29175995",
      "postcode": "6011",
      "mailtown": "Wellington",
      "post_suburb": "Te Aro",
      "post_street": "Willis Street",
      "post_street_name": "Willis",
      "street": "Willis Street",
      "street_name": "Willis",
      "street_type": "street",
      "city": "Wellington",
      "suburb": "Te Aro",
      "region_id": "09",
      "region": "Wellington Region",
      "postal_line_1": "186 Willis Street",
      "postal_line_2": "Te Aro",
      "postal_line_3": "Wellington 6011",
      "dpid": "1499971",
      "rural": false,
      "address_line_1": "186 Willis Street",
      "primary_parcel_id": "3831314",
      "meshblock": "2130700",
      "sa1_id": "7021409",
      "sa2_id": "251600",
      "sa2": "Dixon Street",
      "cb_id": "04799",
      "cb": "Area Outside Community",
      "ward_id": "04703",
      "ward": "Lambton Ward",
      "con_id": "0905",
      "con": "Wellington Constituency",
      "maoricon_id": "0999",
      "maoricon": "Area Outside Maori Constituency",
      "iur_id": "11",
      "iur": "major urban area",
      "ur_id": "1402",
      "ur": "Wellington",
      "landwater_id": "12",
      "landwater": "Mainland",
      "success": true,
      "matched": true
    })
  end
end
