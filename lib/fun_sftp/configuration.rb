module FunSftp
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :log

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
  end
end