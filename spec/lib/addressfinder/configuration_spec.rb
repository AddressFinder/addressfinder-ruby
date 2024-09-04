require 'spec_helper'

RSpec.describe AddressFinder::Configuration do
  it 'sets the client agent with the gem version' do
    config = AddressFinder::Configuration.new
    expect(config.ca).to eq("Ruby/#{AddressFinder::VERSION}")
  end
end