require "redis"
require "active_support/all"
require "http_error"
require "action_throttling/version"
require "action_throttling/configuration"

module ActionThrottling
  MissingConfiguration = Class.new StandardError

  module InstanceMethods
    def cost(price)
      # Deduct the price from the bucket. If it's below zero we raiss a
      # HttpError::ToManyRequests exception/
      if redis.decrby(bucket_key, price) < 0
        raise HttpError::ToManyRequests, "Throttling enabled. Please try again later"
      end
    end

    private

      def bucket_key
        if ActionThrottling.configuration.bucket_key.is_a? Proc
          instance_eval &ActionThrottling.configuration.bucket_key
        else
          ActionThrottling.configuration.bucket_key
        end
      end

      def redis
        @redis ||= Redis.new
      end
  end

  def self.included(receiver)
    unless ActionThrottling.configuration.bucket_key
      raise ActionThrottling::MissingConfiguration,
        'Missing bucket_key configuration. See documentation'
    end

    unless ActionThrottling.configuration.regenerate_interval
      raise ActionThrottling::MissingConfiguration,
        'Missing regenerate_interval configuration. See documentation'
    end

    unless ActionThrottling.configuration.regenerate_amount
      raise ActionThrottling::MissingConfiguration,
        'Missing regenerate_amount configuration. See documentation'
    end

    receiver.send :include, InstanceMethods
  end
end
