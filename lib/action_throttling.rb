require "action_throttling/version"
require "action_throttling/configuration"

module ActionThrottling
  MissingConfiguration = Class.new StandardError

  module InstanceMethods
    def cost(price)
      # Deduct the price from the bucket. If it's below zero we raiss a
      # HttpError::ToManyRequests exception/
      if bucket.deduct(price) < 0
        raise HttpError::ToManyRequests, "Throttling enabled. Please try again later"
      end
    end

    private

      # Evaluate the bucket configuration and return the resulting bucket
      # object.
      def bucket
        @bucket ||= instance_eval &ActionThrottling.configuration.bucket
      end
  end

  def self.included(receiver)
    unless ActionThrottling.configuration.bucket
      raise ActionThrottling::MissingConfiguration,
        'Missing bucket configuration. See documentation'
    end

    unless ActionThrottling.configuration.regenerate
      raise ActionThrottling::MissingConfiguration,
        'Missing regenerate configuration. See documentation'
    end

    receiver.send :include, InstanceMethods
  end
end
