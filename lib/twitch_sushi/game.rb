module TwitchSushi::V5
  class Game
    include TwitchSushi::IdEquality

    attr_reader :id, :channel_count, :viewer_count, :box_images, :giantbomb_id,
                :logo_images, :name, :popularity

    def initialize(hash, query)
      @query = query
      @channel_count = hash['channels']
      @viewer_count = hash['viewers']

      game = hash['game']
      @id = game['_id']
      @box_images = Images.new(game['box'])
      @giantbomb_id = game['giantbomb_id']
      @logo_images = Images.new(game['logo'])
      @name = game['name']
      @popularity = game['popularity']
    end

    def streams(options = {}, &block)
      @query.streams.find(options.merge(:game => @name), &block)
    end
  end

  class GameSuggestion
    include TwitchSushi::IdEquality

    attr_reader :id, :name, :giantbomb_id, :popularity, :box_images, :logo_images

    def initialize(hash)
      @id = hash['_id']
      @name = hash['name']
      @giantbomb_id = hash['giantbomb_id']
      @popularity = hash['popularity']
      @box_images = Images.new(hash['box'])
      @logo_images = Images.new(hash['logo'])
    end
  end

  class Games
    def initialize(query)
      @query = query
    end

    def top(options = {}, &block)
      params = {}

      if options[:hls]
        params[:hls] = true
      end

      return @query.connection.accumulate(
        :path => 'games/top',
        :params => params,
        :json => 'top',
        :create => -> hash { Game.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end

    def find(options)
      raise ArgumentError, 'options' if options.nil?
      raise ArgumentError, 'name' if options[:name].nil?

      params = {
        :query => options[:name],
        :type => 'suggest'
      }

      if options[:live]
        params.merge!(:live => true)
      end

      return @query.connection.accumulate(
        :path => 'search/games',
        :params => params,
        :json => 'games',
        :create => GameSuggestion,
        :limit => options[:limit]
      )
    end
  end
end
