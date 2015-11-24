require 'spec_helper'

RSpec.describe AddressFinder::LocationSearch do
  before do
    AddressFinder.configure do |af|
      af.api_key = 'XXX'
      af.api_secret = 'YYY'
      af.default_country = 'nz'
    end
  end

  describe '#build_request' do
    let(:locator){ AddressFinder::LocationSearch.new(params: args, http: http) }
    let(:http){ AddressFinder.send(:configure_http) }

    subject(:request_uri){ locator.send(:build_request) }

    context 'with minimal arguments' do
      let(:args){ {q: 'willis'} }

      it { expect(request_uri).to eq('/api/nz/location.json?q=willis&key=XXX&secret=YYY') }
    end

    context 'with more arguments' do
      let(:args){ {q: 'willis st', street: 1, max: 10} }

      it { expect(request_uri).to eq('/api/nz/location.json?q=willis%20st&street=1&max=10&key=XXX&secret=YYY') }
    end

    context 'with a country override' do
      let(:args){ {q: 'willis st', country: 'au'} }

      it { expect(request_uri).to eq('/api/au/location.json?q=willis%20st&key=XXX&secret=YYY') }
    end

    context 'with a key override' do
      let(:args){ {q: 'willis st', key: 'AAA'} }

      it { expect(request_uri).to eq('/api/nz/location.json?q=willis%20st&key=AAA&secret=YYY') }
    end

    context 'with a secret override' do
      let(:args){ {q: 'willis st', secret: 'BBB'} }

      it { expect(request_uri).to eq('/api/nz/location.json?q=willis%20st&secret=BBB&key=XXX') }
    end

    context 'with a domain given' do
      let(:args){ {q: '123', domain: 'testdomain.com'} }

      it { expect(request_uri).to eq('/api/nz/location.json?q=123&domain=testdomain.com&key=XXX&secret=YYY') }

      context 'given in the AF configuration' do

        let(:args){ {q: '123'} }

        it 'should use the config domain if set' do
          AddressFinder.configuration.domain = 'anotherdomain.com'
          expect(request_uri).to eq('/api/nz/location.json?q=123&domain=anotherdomain.com&key=XXX&secret=YYY')
          AddressFinder.configuration.domain = nil # set back to nil after
        end
      end
    end
  end

  describe '#build_result' do
    let(:locator){ AddressFinder::LocationSearch.new(params: {q: 'ignored'}, http: nil) }

    before do
      locator.send('response_body=', body)
      locator.send('response_status=', status)
      locator.send(:build_result)
    end

    subject(:results){ locator.results }

    context 'with completions' do
      let(:body){ '{"completions":[{"a":"Willowbank","pxid":"1-.B.3l","v":0},{"a":"Willowby","pxid":"1-.3.4O","v":0}],"paid":true}' }
      let(:status){ '200' }

      it { expect(results.size).to eq(2) }
      it { expect(results.first.class).to eq(AddressFinder::LocationSearch::Result) }
      it { expect(results.first.a).to eq("Willowbank") }
    end

    context 'with no completions' do
      let(:body){ '{"completions":[],"paid":true}' }
      let(:status){ '200' }

      it { expect(results).to eq([]) }
    end
  end
end
