require 'spec_helper'
require 'fileutils'

RSpec.describe AddressFinder do
  before do
    AddressFinder.configure do |af|
      af.api_key = 'XXX'
      af.api_secret = 'YYY'
      af.default_country = 'nz'
      af.timeout = 5
      af.retries = 5
    end
  end

  describe '#verification with verification_version configured to "v2"' do
    before do
      AddressFinder.configuration.verification_version = "v2"
    end

    after do
      AddressFinder.configuration.verification_version = nil # set back to nil after
    end

    subject(:verification){ AddressFinder.verification(args) }

    context "with country set to nz" do
      let(:args){ {country: "nz", q: "12 high street sydney"} }
      it "calls the old class" do
        expect(AddressFinder::Verification).to receive_message_chain(:new, :perform, :result)
        subject
      end
    end

    context "with country set to au" do
      let(:args){ {country: "au", q: "12 high street sydney"} }
      it "calls the v2::Au class" do
        expect(AddressFinder::V2::Au::Verification).to receive_message_chain(:new, :perform, :result)
        subject
      end
    end
  end

  describe '#verification with verification_version not configured' do
    subject(:verification){ AddressFinder.verification(args) }

    context "with country set to nz" do
      let(:args){ {country: "nz", q: "12 high street sydney"} }

      it "calls the old class" do
        expect(AddressFinder::Verification).to receive_message_chain(:new, :perform, :result)
        subject
      end
    end

    context "with country set to au" do
      let(:args){ {country: "au", q: "12 high street sydney"} }

      it "calls the old class" do
        expect(AddressFinder::Verification).to receive_message_chain(:new, :perform, :result)
        subject
      end
    end
  end
end
