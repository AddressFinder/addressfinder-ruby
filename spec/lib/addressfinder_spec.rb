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

      it "safely passes arguments through" do
        nz_verification_endpoint = "https://api.addressfinder.io/api/nz/address/verification"
        stub_request(:get, /\A#{nz_verification_endpoint}/).to_return(:status => 200, :body => "{}", :headers => {})
        subject
      end
    end

    context "with country set to au" do
      let(:args){ {country: "au", q: "12 high street sydney"} }
      it "calls the v2::Au class" do
        expect(AddressFinder::V2::Au::Verification).to receive_message_chain(:new, :perform, :result)
        subject
      end

      it "safely passes arguments through" do
        au_verification_endpoint = "https://api.addressfinder.io/api/au/address/v2/verification"
        stub_request(:get, /\A#{au_verification_endpoint}/).to_return(:status => 200, :body => "{}", :headers => {})
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

  context "#email_verification" do
    subject(:verification) { AddressFinder.email_verification(args) }
    let(:args){ {email: "john.doe@addressfinder.com"} }

    it "calls the email verification class" do
      expect(AddressFinder::V1::Email::Verification).to receive_message_chain(:new, :perform, :result)
      subject
    end
  end

  context "#phone_verification" do
    subject(:verification) { AddressFinder.phone_verification(args) }
    let(:args){ {phone_number: "1800 152 363", default_country_code: "AU"} }

    it "calls the phone verification class" do
      expect(AddressFinder::V1::Phone::Verification).to receive_message_chain(:new, :perform, :result)
      subject
    end
  end
end
