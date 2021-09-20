require 'spec_helper'

RSpec.describe AddressFinder::Verification do
  before do
    AddressFinder.configure do |af|
      af.api_key = 'XXX'
      af.api_secret = 'YYY'
      af.default_country = 'nz'
      af.verification_version = 'v1'
      af.timeout = 5
      af.retries = 3
    end
  end

  let(:verification_module){ AddressFinder::Verification.new(args) }
  let(:http){ AddressFinder::HTTP.new(AddressFinder.configuration) }
  let(:net_http){ http.send(:net_http) }

  describe '#execute_request' do
    let(:args){ {q: "186 Willis Street", http: http} }

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

  describe '#build_request' do
    subject(:request_uri){ verification_module.send(:build_request) }

    context 'with minimal arguments' do
      let(:args){ {q: '186 willis st', http: http} }

      it { expect(request_uri).to eq('/api/nz/address/verification?q=186+willis+st&key=XXX&secret=YYY&format=json') }
    end

    context 'with more arguments' do
      let(:args){ {q: '186 willis st', delivered: true, region_code: 'A', census: '2013', http: http} }

      it { expect(request_uri).to eq('/api/nz/address/verification?q=186+willis+st&census=2013&key=XXX&secret=YYY&delivered=true&region_code=A&format=json') }
    end

    context 'with a country override' do
      let(:args){ {q: '186 willis st', country: 'au', http: http} }

      it { expect(request_uri).to eq('/api/au/address/verification?q=186+willis+st&key=XXX&secret=YYY&format=json') }
    end

    context 'with a state codes as an array' do
      let(:args){ {q: '186 willis st', country: 'au', state_codes: ['ACT','NSW'], http: http} }

      it { expect(request_uri).to eq('/api/au/address/verification?q=186+willis+st&key=XXX&secret=YYY&state_codes[]=ACT&state_codes[]=NSW&format=json') }
    end

    context 'with a reserved character in the query' do
      let(:args){ {q: '186=willis st', country: 'au', state_codes: ['ACT','NSW'], http: http} }

      it { expect(request_uri).to eq('/api/au/address/verification?q=186%3Dwillis+st&key=XXX&secret=YYY&state_codes[]=ACT&state_codes[]=NSW&format=json') }
    end

    context 'with a state codes as a string' do
      let(:args){ {q: '186 willis st', country: 'au', state_codes: 'ACT,NSW', http: http} }

      it { expect(request_uri).to eq('/api/au/address/verification?q=186+willis+st&key=XXX&secret=YYY&state_codes=ACT%2CNSW&format=json') }
    end

    context 'with a key override' do
      let(:args){ {q: '186 willis st', key: 'AAA', http: http} }

      it { expect(request_uri).to eq('/api/nz/address/verification?q=186+willis+st&key=AAA&secret=YYY&format=json') }
    end

    context 'with a secret override' do
      let(:args){ {q: '186 willis st', secret: 'BBB', http: http} }

      it { expect(request_uri).to eq('/api/nz/address/verification?q=186+willis+st&key=XXX&secret=BBB&format=json') }
    end

    context 'with a domain given' do
      let(:args){ {q: '123', domain: 'testdomain.com', http: http} }

      it { expect(request_uri).to eq('/api/nz/address/verification?q=123&domain=testdomain.com&key=XXX&secret=YYY&format=json') }

      context 'given in the AF configuration' do

        let(:args){ {q: '123', http: http} }

        it 'should use the config domain if set' do
          AddressFinder.configuration.domain = 'anotherdomain.com'
          expect(request_uri).to eq('/api/nz/address/verification?q=123&domain=anotherdomain.com&key=XXX&secret=YYY&format=json')
          AddressFinder.configuration.domain = nil # set back to nil after
        end
      end
    end
  end

  describe '#build_result' do
    let(:args){ {q: 'ignored', http: nil} }

    before do
      verification_module.send('response_body=', body)
      verification_module.send('response_status=', status)
    end

    subject(:result){ verification_module.send(:build_result) }

    context 'with a successful nz result' do
      let(:body){ '{"matched": true, "postal_address": "Texas"}' }
      let(:status){ '200' }

      it { expect(result.class).to eq(AddressFinder::Verification::Result) }

      it { expect(result.matched).to eq(true) }

      it { expect(result.postal_address).to eq("Texas") }
    end

    context 'with a successful au result' do
      let(:body){ %Q({"matched": true, "success": true, "address": {"full_address": "Texas"}}) }
      let(:status){ '200' }

      it { expect(result.class).to eq(AddressFinder::Verification::Result) }

      it { expect(result.full_address).to eq("Texas") }
    end

    context 'with an unfound result' do
      let(:body){ '{"matched": false}' }
      let(:status){ '200' }

      it { expect(result).to eq(nil) }
    end
  end
end
