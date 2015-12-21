require 'addressfinder/util'

RSpec.describe AddressFinder::Util do
  describe '.encode_and_join_params' do
    subject { AddressFinder::Util.encode_and_join_params(params) }

    context 'with a question mark value' do
      let(:params){ {q:'?',format:'json',key:'XXX',secret:'YYY'} }

      it { is_expected.to eq('q=%3F&format=json&key=XXX&secret=YYY') }
    end

    context 'with an ampersand value' do
      let(:params){ {q:'&',format:'json',key:'XXX',secret:'YYY'} }

      it { is_expected.to eq('q=%26&format=json&key=XXX&secret=YYY') }
    end

    context 'with a normal address value' do
      let(:params){ {q:'12 high',format:'json',key:'XXX',secret:'YYY'} }

      it { is_expected.to eq('q=12+high&format=json&key=XXX&secret=YYY') }
    end

    context 'with a blank value' do
      let(:params){ {q:'',format:'json',key:'XXX',secret:'YYY'} }

      it { is_expected.to eq('q=&format=json&key=XXX&secret=YYY') }
    end

    context 'with a nil value' do
      let(:params){ {q:nil,format:'json',key:'XXX',secret:'YYY'} }

      it { is_expected.to eq('q=&format=json&key=XXX&secret=YYY') }
    end
  end
end