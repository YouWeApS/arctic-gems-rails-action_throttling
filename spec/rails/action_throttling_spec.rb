ActionThrottling.configure do |config|
  config.bucket_key = 'a'
  config.regenerate_interval = 10.minutes
  config.regenerate_amount = 100
end

class ActionThrottlingTest
  include ActionThrottling
end

RSpec.describe ActionThrottlingTest do
  describe '#cost' do
    subject { described_class.new.cost(value) }
    let(:value) { 10 }

    it 'raises HttpError::ToManyRequests if no tokens left in bucket' do
      expect { subject }.to raise_error HttpError::ToManyRequests
    end

    context 'with tokens in bucket' do
      before { Redis.new.set(ActionThrottling.configuration.bucket_key, 11) }

      it 'raises HttpError::ToManyRequests if no tokens left in bucket' do
        expect { subject }.not_to raise_error HttpError::ToManyRequests
      end
    end
  end
end
