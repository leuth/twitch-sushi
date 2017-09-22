require 'cgi'

module TwitchSushi::V5
  class Stream
    include TwitchSushi::IdEquality

    attr_reader :average_fps, :channel, :created_at, :delay, :id, :game_name,
                :name, :preview_url, :url, :video_height, :viewer_count

    def initialize(hash, query)
      @query = query
      @id = hash['_id']
      @game_name = hash['game']
      @viewer_count = hash['viewers']
      @video_height = hash['video_height']
      @average_fps = hash['average_fps']
      @delay = hash['delay']
      @created_at = hash['created_at']
      @is_playlist = hash['is_playlist']
      @preview_url = hash['preview']
      @channel = Channel.new(hash['channel'], @query)
      @name = @channel.name
      @url = @channel.url
    end

    def playlist?
      @playlist
    end

    def user
      @query.users.get(@channel.name)
    end
  end

  class StreamSummary
    attr_reader :channel_count, :viewer_count

    def initialize(hash)
      @viewer_count = hash['viewers']
      @channel_count = hash['channels']
    end
  end

  class Streams
    def initialize(query)
      @query = query
    end

    def get(stream_name)
      name = CGI.escape(stream_name)
      query = { login: name }
      user_json = @query.connection.get('users', query)
      userhash = user_json['users'][0]
      id = userhash['_id']
      TwitchSushi::Status.map(404 => nil, 422 => nil) do
        json = @query.connection.get("streams/#{id}")
        stream = json['stream']
        stream.nil? ? nil : Stream.new(stream, @query)
      end
    end

    def all(options = {}, &block)
      return @query.connection.accumulate(
        :path => 'streams',
        :json => 'streams',
        :create => -> hash { Stream.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end

    def find(options, &block)
      check = options.dup
      check.delete(:limit)
      check.delete(:offset)
      raise ArgumentError, 'options' if check.empty?

      params = {}
      channels = options[:channel]
      if channels
        if !channels.respond_to?(:map)
          raise ArgumentError, ':channel'
        end

        params[:channel] = channels.map { |channel|
          if channel.respond_to?(:name)
            channel.name
          else
            channel.to_s
          end
        }.join(',')
      end

      game = options[:game]
      if game
        if game.respond_to?(:name)
          params[:game] = game.name
        else
          params[:game] = game.to_s
        end
      end

      if options[:hls]
        params[:hls] = true
      end

      if options[:embeddable]
        params[:embeddable] = true
      end

      return @query.connection.accumulate(
        :path => 'streams',
        :params => params,
        :json => 'streams',
        :create => -> hash { Stream.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end

    def featured(options = {}, &block)
      params = {}

      if options[:hls]
        params[:hls] = true
      end

      return @query.connection.accumulate(
        :path => 'streams/featured',
        :params => params,
        :json => 'featured',
        :sub_json => 'stream',
        :create => -> hash { Stream.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end

    def summary
      json = @query.connection.get('streams/summary')
      StreamSummary.new(json)
    end
  end
end
