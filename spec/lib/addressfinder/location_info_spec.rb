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
    let(:locator){ AddressFinder::LocationInfo.new(args) }
    let(:http){ AddressFinder.send(:configure_http) }

    subject(:request_uri){ locator.send(:build_request) }

    context 'with a simple PXID' do
      let(:args){ {pxid: '123', http: http} }

      it { expect(request_uri).to eq('/api/au/location/info.json?pxid=123&key=XXX&secret=YYY') }
    end

    context 'with a country override' do
      let(:args){ {pxid: '123', http: http} }

      it { expect(request_uri).to eq('/api/au/location/info.json?pxid=123&key=XXX&secret=YYY') }
    end
  end
end
