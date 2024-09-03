require 'spec_helper'

RSpec.describe AddressFinder::Configuration do
  it 'sets the client agent with the gem version' do
    config = AddressFinder::Configuration.new
    expect(config.ca).to eq("Ruby/#{AddressFinder::VERSION}")
  end

  it 'does not allow the client agent to be modified' do
    config = AddressFinder::Configuration.new
    expect { config.ca = "CustomAgent/1.0" }.to raise_error(NoMethodError)
  end
end