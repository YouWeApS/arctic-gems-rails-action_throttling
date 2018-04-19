require "redis"
require "active_support/all"
require "http_error"
require "action_throttling/version"
require "action_throttling/configuration"

module ActionThrottling
  MissingConfiguration = Class.new StandardError

  module InstanceMethods
    def cost(price)
      # If last time the bucket was called is older than the regeneration limit
      # regenerate the bucket.
      refill if cooled_down?

      # Deduct the price from the bucket. If it's below zero we raiss a
      # HttpError::ToManyRequests exception/
      if redis.decrby(bucket_key, price) < 0
        raise HttpError::ToManyRequests, "Throttling enabled. Please try again later"
      end

      # Store when the cost was last called so we can calculate regeneration
      redis.set last_call_key, Time.now.httpdate
    end

    private
      def cooled_down?
        last_called < timeout
      end

      def last_call_key
        "#{bucket_key}-last-call"
      end

      def refill
        redis.set bucket_key, regenerate_amount
      end

      def regenerate_amount
        instance_eval &ActionThrottling.configuration.regenerate_amount
      end

      def last_called
        value = redis.get(last_call_key).presence

        # trigger regeneration when first cost is first called
        value ||= (timeout - 1.second).httpdate

        Time.parse value
      end

      def bucket_key
        instance_eval &ActionThrottling.configuration.bucket_key
      end

      def timeout
        instance_eval(&ActionThrottling.configuration.timeout).ago
      end

      def redis
        @redis ||= ActionThrottling.configuration.redis
      end
  end

  def self.included(receiver)
    unless ActionThrottling.configuration.bucket_key
      raise ActionThrottling::MissingConfiguration,
        'Missing bucket_key configuration. See documentation'
    end

    unless ActionThrottling.configuration.timeout
      raise ActionThrottling::MissingConfiguration,
        'Missing timeout configuration. See documentation'
    end

    unless ActionThrottling.configuration.regenerate_amount
      raise ActionThrottling::MissingConfiguration,
        'Missing regenerate_amount configuration. See documentation'
    end

    receiver.send :include, InstanceMethods
  end
end
