require "spec_helper"

RSpec.describe AddressFinder::V1::Phone::Verification do
  before do
    AddressFinder.configure do |af|
      af.api_key = "XXX"
      af.api_secret = "YYY"
      af.timeout = 5
      af.retries = 3
    end
  end

  let(:verification_module){ AddressFinder::V1::Phone::Verification.new(**args) }
  let(:http){ AddressFinder::HTTP.new(AddressFinder.configuration) }
  let(:net_http){ http.send(:net_http) }

  describe "#execute_request" do
    let(:args){ {phone_number: "1800 152 363", default_country_code: "AU", http: http} }

    before do
      WebMock.allow_net_connect!(net_http_connect_on_start: true)
      allow(http).to receive(:sleep)
      allow(verification_module).to receive(:request_uri).and_return("/test/path")
      expect(http).to_not receive(:re_establish_connection)
    end

    after do
      WebMock.disable_net_connect!
    end

    subject(:execute_request){ verification_module.send(:execute_request) }

    it "retries an errored request another time before succeeding" do
      expect(net_http).to receive(:do_start).twice.and_call_original
      expect(net_http).to receive(:transport_request).once.and_raise(Net::OpenTimeout)
      expect(net_http).to receive(:transport_request).once.and_return(double(:response, body: "OK", code: "200"))
      expect(net_http).to receive(:do_finish).twice.and_call_original
      execute_request
    end

    it "re-raises a Net::OpenTimeout error after 3 retries" do
      expect(net_http).to receive(:do_start).exactly(4).times.and_call_original
      expect(net_http).to receive(:transport_request).exactly(4).times.and_raise(Net::OpenTimeout)
      expect(net_http).to receive(:do_finish).exactly(4).times.and_call_original
      expect{execute_request}.to raise_error(Net::OpenTimeout)
    end

    it "re-raises a Net::ReadTimeout error after 3 retries" do
      expect(net_http).to receive(:do_start).exactly(4).times.and_call_original
      expect(net_http).to receive(:transport_request).exactly(4).times.and_raise(Net::ReadTimeout)
      expect(net_http).to receive(:do_finish).exactly(4).times.and_call_original
      expect{execute_request}.to raise_error(Net::ReadTimeout)
    end

    it "re-raises a SocketError error after 3 retries" do
      expect(net_http).to receive(:do_start).exactly(4).times.and_call_original
      expect(net_http).to receive(:transport_request).exactly(4).times.and_raise(SocketError)
      expect(net_http).to receive(:do_finish).exactly(4).times.and_call_original
      expect{execute_request}.to raise_error(SocketError)
    end
  end

  describe "#build_request" do
    subject(:request_uri){ verification_module.send(:build_request) }

    context "with phone number and default country code arguments" do
      let(:args){ {phone_number: "1800 152 363", default_country_code: "AU", http: http} }

      it { expect(request_uri).to eq("/api/phone/v1/verification?phone_number=1800+152+363&default_country_code=AU&key=XXX&secret=YYY&format=json") }
    end

    context "with a reserved character in the phone number" do
      let(:args){ {phone_number: "1800= 152 363", default_country_code: "AU", http: http} }

      it { expect(request_uri).to eq("/api/phone/v1/verification?phone_number=1800%3D+152+363&default_country_code=AU&key=XXX&secret=YYY&format=json") }
    end

    context "with a key override" do
      let(:args){ {phone_number: "1800 152 363", default_country_code: "AU", key: "AAA", http: http} }

      it { expect(request_uri).to eq("/api/phone/v1/verification?phone_number=1800+152+363&default_country_code=AU&key=AAA&secret=YYY&format=json") }
    end

    context "with a secret override" do
      let(:args){ {phone_number: "1800 152 363", default_country_code: "AU", secret: "BBB", http: http} }

      it { expect(request_uri).to eq("/api/phone/v1/verification?phone_number=1800+152+363&default_country_code=AU&key=XXX&secret=BBB&format=json") }
    end

    context "with a domain given" do
      let(:args){ {phone_number: "1800 152 363", default_country_code: "AU", domain: "testdomain.com", http: http} }

      it { expect(request_uri).to eq("/api/phone/v1/verification?phone_number=1800+152+363&default_country_code=AU&domain=testdomain.com&key=XXX&secret=YYY&format=json") }

      context "given in the AF configuration" do
        let(:args){ {phone_number: "1800 152 363", default_country_code: "AU", http: http} }

        it "should use the config domain if set" do
          AddressFinder.configuration.domain = "anotherdomain.com"
          expect(request_uri).to eq("/api/phone/v1/verification?phone_number=1800+152+363&default_country_code=AU&domain=anotherdomain.com&key=XXX&secret=YYY&format=json")
          AddressFinder.configuration.domain = nil # set back to nil after
        end
      end
    end

    context "with a all arguments included in request" do
      let(:args){ {phone_number: "1800 152 363", default_country_code: "NZ", allowed_country_codes: "AU,NZ", mobile_only: true, timeout: "10", domain: "mysite.com", format: "xml", http: http} }

      it { expect(request_uri).to eq("/api/phone/v1/verification?phone_number=1800+152+363&default_country_code=NZ&allowed_country_codes=AU%2CNZ&mobile_only=true&timeout=10&domain=mysite.com&key=XXX&secret=YYY&format=xml") }
    end
  end

  describe "#build_result" do
    let(:args){ {phone_number: "ignored", default_country_code: "ignored", http: nil} }

    before do
      verification_module.send("response_body=", body)
      verification_module.send("response_status=", status)
    end

    subject(:result){ verification_module.send(:build_result) }

    context "with a successful verification" do
      let(:body){ '{"raw_international": "+611800152353", "line_type": "toll_free", "line_status": "disconnected", "is_verified": true, "success": true}' }
      let(:status){ "200" }

      it { expect(result.class).to eq(AddressFinder::V1::Phone::Verification::Result) }
      it { expect(result.is_verified).to eq(true) }
      it { expect(result.raw_international).to eq("+611800152353") }
      it { expect(result.line_type).to eq("toll_free") }
      it { expect(result.line_status).to eq("disconnected") }
    end

    context "with an unsuccessful verification" do
      let(:body){ '{"is_verified": false, "not_verified_reason": "Phone number format is incorrect", "not_verified_code": "INVALID_FORMAT", "success": true}' }
      let(:status){ "200" }

      it { expect(result.class).to eq(AddressFinder::V1::Phone::Verification::Result) }
      it { expect(result.is_verified).to eq(false) }
      it { expect(result.not_verified_code).to eq("INVALID_FORMAT") }
      it { expect(result.not_verified_reason).to eq("Phone number format is incorrect") }
    end
  end
end