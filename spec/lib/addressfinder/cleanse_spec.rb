require 'spec_helper'

RSpec.describe AddressFinder::Cleanse do
  before do
    AddressFinder.configure do |af|
      af.api_key = 'XXX'
      af.api_secret = 'YYY'
      af.default_country = 'nz'
    end
  end

  describe '#build_request' do
    let(:cleanser){ AddressFinder::Cleanse.new(args) }
    let(:http){ AddressFinder.send(:configure_http) }

    subject(:request_uri){ cleanser.send(:build_request) }

    context 'with minimal arguments' do
      let(:args){ {q: '186 willis st', http: http} }

      it { expect(request_uri).to eq('/api/nz/address/cleanse?q=186%20willis%20st&format=json&key=XXX&secret=YYY') }
    end

    context 'with more arguments' do
      let(:args){ {q: '186 willis st', delivered: true, region_code: 'A', http: http} }

      it { expect(request_uri).to eq('/api/nz/address/cleanse?q=186%20willis%20st&delivered=true&region_code=A&format=json&key=XXX&secret=YYY') }
    end

    context 'with a country override' do
      let(:args){ {q: '186 willis st', country: 'au', http: http} }

      it { expect(request_uri).to eq('/api/au/address/cleanse?q=186%20willis%20st&format=json&key=XXX&secret=YYY') }
    end
  end

  describe '#build_result' do
    let(:cleanser){ AddressFinder::Cleanse.new(q: 'ignored', http: nil) }

    before do
      cleanser.send('response_body=', body)
      cleanser.send('response_status=', status)
    end

    subject(:result){ cleanser.send(:build_result) }

    context 'with a successful result' do
      let(:body){ '{"matched": true, "postal_address": "Texas"}' }
      let(:status){ '200' }

      it { expect(result.class).to eq(AddressFinder::Cleanse::Result) }

      it { expect(result.matched).to eq(true) }

      it { expect(result.postal_address).to eq("Texas") }
    end

    context 'with an unfound result' do
      let(:body){ '{"matched": false}' }
      let(:status){ '200' }

      it { expect(result).to eq(nil) }
    end
  end
end
