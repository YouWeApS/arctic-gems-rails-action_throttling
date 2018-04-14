module ActionThrottling
  class Configuration
    attr_accessor :bucket, :regenerate
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
