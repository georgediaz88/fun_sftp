module FunSftp
  class << self
    attr_accessor :configuration
  end

  def self.configure
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.logger
    if loggable?
      configuration and configuration.logger
    end
  end

  def self.loggable?
    (configuration and !configuration.log) ? false : true
  end

  class Configuration
    attr_accessor :log, :logger

    def initialize
      @log = true
    end

    def log=(val)
      if [true, false].include?(val)
        @log = val
      else
        raise ArgumentError, "#{val} is not a correct value to set. Must be of either: [true, false]"
      end
    end

    def logger
      @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    end
  end
end