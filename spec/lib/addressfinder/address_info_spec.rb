require 'spec_helper'

RSpec.describe AddressFinder::AddressInfo do
  before do
    AddressFinder.configure do |af|
      af.api_key = 'XXX'
      af.api_secret = 'YYY'
      af.default_country = 'au'
    end
  end

  describe '#build_request' do
    let(:locator){ AddressFinder::AddressInfo.new(params: args, http: http) }
    let(:http){ AddressFinder.send(:configure_http) }

    subject(:request_uri){ locator.send(:build_request) }

    context 'with a simple PXID' do
      let(:args){ {pxid: '123'} }

      it { expect(request_uri).to eq('/api/au/address/info.json?pxid=123&key=XXX&secret=YYY') }
    end

    context 'with a country override' do
      let(:args){ {pxid: '123'} }

      it { expect(request_uri).to eq('/api/au/address/info.json?pxid=123&key=XXX&secret=YYY') }
    end
  end

  describe '#build_result' do
    let(:locator){ AddressFinder::AddressInfo.new(params: {q: 'ignored'}, http: nil) }

    before do
      locator.send('response_body=', body)
      locator.send('response_status=', status)
    end

    subject(:result){ locator.send(:build_result) }

    context 'with a successful result' do
      let(:body){ '{"pxid":"2-.9.2U.F.F.2I","number":"184","container_only":"false","x":"174.314855382547","y":"-35.6946659390092","postcode":"0112","a":"184 William Jones Drive, Otangarei, Whangarei 0112","postal":"184 William Jones Drive, Otangarei, Whangarei 0112","mailtown":"Whangarei","post_suburb":"Otangarei","ta":"Whangarei District","sufi":932755,"street_type":"drive","city":"Whangarei","suburb":"Otangarei","region":"Northland Region","street":"William Jones Drive","postal_line_1":"184 William Jones Drive","postal_line_2":"Otangarei","postal_line_3":"Whangarei 0112","meshblock":"93700","dpid":"681856"}' }
      let(:status){ '200' }

      it { expect(result.class).to eq(AddressFinder::AddressInfo::Result) }
      it { expect(result.a).to eq("184 William Jones Drive, Otangarei, Whangarei 0112") }
      it { expect(result.pxid).to eq("2-.9.2U.F.F.2I") }
    end
  end
end
