ActionThrottling.configure do |config|
  config.bucket_key = 'a'
  config.regenerate_interval = 10.minutes
  config.regenerate_amount = 100
end

class ActionThrottlingTest
  include ActionThrottling
end

RSpec.describe ActionThrottlingTest do
  let(:instance) { described_class.new }

  describe '#cost' do
    subject { instance.cost(value) }
    let(:value) { 10 }

    it 'raises HttpError::ToManyRequests if no tokens left in bucket' do
      Redis.new.set ActionThrottling.configuration.bucket_key, 9
      expect { subject }.to raise_error HttpError::ToManyRequests
    end

    it 'does not raise anything when sufficient tokens left' do
      Redis.new.set ActionThrottling.configuration.bucket_key, 11
      expect { subject }.not_to raise_error HttpError::ToManyRequests
    end

    it 'regenerates the bucket upon first call' do
      Redis.new.del instance.send :last_call_key
      expect { subject }.not_to raise_error HttpError::ToManyRequests
      expect(Redis.new.get(instance.send(:last_call_key))).to be_present
    end
  end
end
