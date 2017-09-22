require 'cgi'
require 'time'

module TwitchSushi::V5
  class ChannelProxy
    include Proxy
    proxy {
      @query.channels.get(@name)
    }

    attr_reader :display_name, :name

    def initialize(name, display_name, query)
      @name = name
      @display_name = display_name
      @query = query
    end
  end

  class Video
    include TwitchSushi::IdEquality

    attr_reader :id, :channel, :description, :game_name, :length, :recorded_at,
                :preview_url, :title, :url, :view_count

    def initialize(hash, query)
      @id = hash['_id']
      @title = hash['title']
      @recorded_at = Time.parse(hash['recorded_at']).utc
      @url = hash['url']
      @view_count = hash['views']
      @description = hash['description']
      @length = hash['length']
      @game_name = hash['game']
      @preview_url = hash['preview']

      @channel = ChannelProxy.new(
        hash['channel']['name'],
        hash['channel']['display_name'],
        query
      )
    end
  end

  class Videos
    def initialize(query)
      @query = query
    end

    def get(id)
      raise ArgumentError, 'id' if !id || id.strip.empty?

      id = CGI.escape(id)
      TwitchSushi::Status.map(404 => nil) do
        json = @query.connection.get("videos/#{id}")
        Video.new(json, @query)
      end
    end

    def top(options = {}, &block)
      params = {}

      if options[:game]
        params[:game] = options[:game]
      end

      period = options[:period] || :week
      if ![:week, :month, :all].include?(period)
        raise ArgumentError, 'period'
      end

      params[:period] = period.to_s

      return @query.connection.accumulate(
        path: 'videos/top',
        params: params,
        json: 'videos',
        create: -> hash { Video.new(hash, @query) },
        limit: options[:limit],
        offset: options[:offset],
        &block
      )
    end

    def for_channel(channel, options = {})
      channel_id = channel.id
      params = {}
      type = options[:type] || :highlights
      if !type.nil?
        if ![:broadcasts, :highlights].include?(type)
          raise ArgumentError, 'type'
        end

        params[:broadcasts] = (type == :broadcasts)
      end

      id = CGI.escape(channel_id)
      return @query.connection.accumulate(
        path: "channels/#{id}/videos",
        params: params,
        json: 'videos',
        create: -> hash { Video.new(hash, @query) },
        limit: options[:limit],
        offset: options[:offset]
      )
    end
  end
end
