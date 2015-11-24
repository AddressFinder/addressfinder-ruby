require 'spec_helper'

RSpec.describe AddressFinder::AddressSearch do
  before do
    AddressFinder.configure do |af|
      af.api_key = 'XXX'
      af.api_secret = 'YYY'
      af.default_country = 'nz'
    end
  end

  describe '#build_request' do
    let(:locator){ AddressFinder::AddressSearch.new(params: args, http: http) }
    let(:http){ AddressFinder.send(:configure_http) }

    subject(:request_uri){ locator.send(:build_request) }

    context 'with minimal arguments' do
      let(:args){ {q: '186 willis'} }

      it { expect(request_uri).to eq('/api/nz/address.json?q=186%20willis&key=XXX&secret=YYY') }
    end

    context 'with more arguments' do
      let(:args){ {q: '186 willis st', delivered: 1, max: 10} }

      it { expect(request_uri).to eq('/api/nz/address.json?q=186%20willis%20st&delivered=1&max=10&key=XXX&secret=YYY') }
    end

    context 'with a country override' do
      let(:args){ {q: '186 willis st', country: 'au'} }

      it { expect(request_uri).to eq('/api/au/address.json?q=186%20willis%20st&key=XXX&secret=YYY') }
    end
  end

  describe '#build_result' do
    let(:locator){ AddressFinder::AddressSearch.new(params: {q: 'ignored'}, http: nil) }

    before do
      locator.send('response_body=', body)
      locator.send('response_status=', status)
      locator.send(:build_result)
    end

    subject(:results){ locator.results }

    context 'with completions' do
      let(:body){ '{"completions":[{"a":"184 William Jones Drive, Otangarei, Whangarei 0112","pxid":"2-.9.2U.F.F.2I","v":1},{"a":"184 Williams Street, Kaiapoi 7630","pxid":"2-.3.1q.2.4G.4c","v":0},{"a":"184 Willis Street, Te Aro, Wellington 6011","pxid":"2-.F.1W.p.1D.1W","v":0}],"paid":true}' }
      let(:status){ '200' }

      it { expect(results.size).to eq(3) }
      it { expect(results.first.class).to eq(AddressFinder::AddressSearch::Result) }
      it { expect(results.first.a).to eq("184 William Jones Drive, Otangarei, Whangarei 0112") }
    end

    context 'with no completions' do
      let(:body){ '{"completions":[],"paid":true}' }
      let(:status){ '200' }

      it { expect(results).to eq([]) }
    end
  end
end
