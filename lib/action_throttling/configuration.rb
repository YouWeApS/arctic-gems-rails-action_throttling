module ActionThrottling
  class Configuration
    attr_accessor :bucket_key, :regenerate_amount, :regenerate_interval
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end
end
