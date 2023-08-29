require "spec_helper"

RSpec.describe AddressFinder::V1::Email::Verification do
  before do
    AddressFinder.configure do |af|
      af.api_key = "XXX"
      af.api_secret = "YYY"
      af.timeout = 5
      af.retries = 3
    end
  end

  let(:verification_module){ AddressFinder::V1::Email::Verification.new(**args) }
  let(:http){ AddressFinder::HTTP.new(AddressFinder.configuration) }
  let(:net_http){ http.send(:net_http) }

  describe "#execute_request" do
    let(:args){ {email: "john.doe@addressfinder.com", http: http} }

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

    context "with email argument" do
      let(:args){ {email: "john.doe@addressfinder.com", http: http} }

      it { expect(request_uri).to eq("/api/email/v1/verification?email=john.doe%40addressfinder.com&key=XXX&secret=YYY&format=json") }
    end

    context "with email and format arguments" do
      let(:args){ {email: "john.doe@addressfinder.com", format: "xml", http: http} }

      it { expect(request_uri).to eq("/api/email/v1/verification?email=john.doe%40addressfinder.com&key=XXX&secret=YYY&format=xml") }
    end

    context "with a reserved character in the email" do
      let(:args){ {email: "john=doe@addressfinder.com", http: http} }

      it { expect(request_uri).to eq("/api/email/v1/verification?email=john%3Ddoe%40addressfinder.com&key=XXX&secret=YYY&format=json") }
    end

    context "with a key override" do
      let(:args){ {email: "john.doe@addressfinder.com", key: "AAA", http: http} }

      it { expect(request_uri).to eq("/api/email/v1/verification?email=john.doe%40addressfinder.com&key=AAA&secret=YYY&format=json") }
    end

    context "with a secret override" do
      let(:args){ {email: "john.doe@addressfinder.com", secret: "BBB", http: http} }

      it { expect(request_uri).to eq("/api/email/v1/verification?email=john.doe%40addressfinder.com&key=XXX&secret=BBB&format=json") }
    end

    context "with a domain given" do
      let(:args){ {email: "john.doe@addressfinder.com", domain: "testdomain.com", http: http} }

      it { expect(request_uri).to eq("/api/email/v1/verification?email=john.doe%40addressfinder.com&domain=testdomain.com&key=XXX&secret=YYY&format=json") }

      context "given in the AF configuration" do
        let(:args){ {email: "john.doe@addressfinder.com", http: http} }

        it "should use the config domain if set" do
          AddressFinder.configuration.domain = "anotherdomain.com"
          expect(request_uri).to eq("/api/email/v1/verification?email=john.doe%40addressfinder.com&domain=anotherdomain.com&key=XXX&secret=YYY&format=json")
          AddressFinder.configuration.domain = nil # set back to nil after
        end
      end
    end

    context "with a all arguments included in request" do
      let(:args){ {email: "john.doe@addressfinder.com", domain: "mysite.com", format: "json", http: http} }

      it { expect(request_uri).to eq("/api/email/v1/verification?email=john.doe%40addressfinder.com&domain=mysite.com&key=XXX&secret=YYY&format=json") }
    end
  end

  describe "#build_result" do
    let(:args){ {email: "ignored", http: nil} }

    before do
      verification_module.send("response_body=", body)
      verification_module.send("response_status=", status)
    end

    subject(:result){ verification_module.send(:build_result) }

    context "with a successful verification" do
      let(:body){ '{"email_account": "john.doe", "email_domain": "addressfinder.com", "is_verified": true, "success": true}' }
      let(:status){ "200" }

      it { expect(result.class).to eq(AddressFinder::V1::Email::Verification::Result) }
      it { expect(result.is_verified).to eq(true) }
      it { expect(result.email_account).to eq("john.doe") }
    end

    context "with an unsuccessful verification" do
      let(:body){ '{"email_account": "jane.doe", "email_domain": "addressfinder.com", "is_verified": false, "not_verified_reason": "The email account does not exist", "success": true}' }
      let(:status){ "200" }

      it { expect(result.class).to eq(AddressFinder::V1::Email::Verification::Result) }
      it { expect(result.is_verified).to eq(false) }
      it { expect(result.email_account).to eq("jane.doe") }
      it { expect(result.not_verified_reason).to eq("The email account does not exist") }
    end
  end
end