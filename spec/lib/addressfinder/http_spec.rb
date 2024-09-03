require 'spec_helper'

RSpec.describe AddressFinder::HTTP do
  let(:config) { AddressFinder::Configuration.new }
  let(:http) { described_class.new(config) }
  let(:request_uri) { "https://api.addressfinder.io?param=value" }

  describe '#build_uri' do
    it 'appends the ca parameter to the query string' do
      uri_with_ca = http.send(:build_uri, request_uri)
      expect(uri_with_ca).to include("ca=Ruby%2F#{AddressFinder::VERSION}")
    end

    it 'preserves existing query parameters' do
      uri_with_ca = http.send(:build_uri, request_uri)
      expect(uri_with_ca).to include("param=value")
    end
  end
end
