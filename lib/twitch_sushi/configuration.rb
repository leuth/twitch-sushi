require 'securerandom'

module TwitchSushi
  @query = nil

  def self.configure(&block)
    @query = instance(&block)
    nil
  end

  def self.instance(&block)
    config = Configuration.new
    config.instance_eval(&block)
    connection = config.create(:Connection, config.client_id)
    return config.create(:Query, connection)
  end

  def self.method_missing(*args)
    @query ||= create_default_query
    @query.send(*args)
  end

  class Configuration
    def initialize
      @api = TwitchSushi::V5
    end

    def client_id
      @client_id ||= "TwitchSushi-%s" % SecureRandom.uuid
      @client_id
    end

    def create(symbol, *args)
      @api.const_get(symbol).new(*args)
    end

    attr_writer :client_id
    attr_accessor :api
  end

private
  # @private
  def self.create_default_query
    config = Configuration.new
    connection = config.create(:Connection, config.client_id)
    return config.create(:Query, connection)
  end
end
