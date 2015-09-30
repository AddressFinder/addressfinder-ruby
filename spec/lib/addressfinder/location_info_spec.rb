require 'spec_helper'

RSpec.describe AddressFinder::LocationInfo do
  before do
    AddressFinder.configure do |af|
      af.api_key = 'XXX'
      af.api_secret = 'YYY'
      af.default_country = 'au'
    end
  end

  describe '#build_request' do
    let(:locator){ AddressFinder::LocationInfo.new(params: args, http: http) }
    let(:http){ AddressFinder.send(:configure_http) }

    subject(:request_uri){ locator.send(:build_request) }

    context 'with a simple PXID' do
      let(:args){ {pxid: '123'} }

      it { expect(request_uri).to eq('/api/au/location/info.json?pxid=123&key=XXX&secret=YYY') }
    end

    context 'with a country override' do
      let(:args){ {pxid: '123'} }

      it { expect(request_uri).to eq('/api/au/location/info.json?pxid=123&key=XXX&secret=YYY') }
    end
  end

  describe '#build_result' do
    let(:locator){ AddressFinder::LocationInfo.new(params: {q: 'ignored'}, http: nil) }

    before do
      locator.send('response_body=', body)
      locator.send('response_status=', status)
    end

    subject(:result){ locator.send(:build_result) }

    context 'with a successful result' do
      let(:body){ '{"a":"Seaview Road, Glenfield, Auckland","city":"Auckland","suburb":"Glenfield","region":"Auckland Region","x":174.713938691835,"y":-36.7894885545157,"pxid":"1-.1.6.j.1F","street":"Seaview Road"}' }
      let(:status){ '200' }

      it { expect(result.class).to eq(AddressFinder::LocationInfo::Result) }
      it { expect(result.a).to eq("Seaview Road, Glenfield, Auckland") }
      it { expect(result.pxid).to eq("1-.1.6.j.1F") }
    end
  end
end
