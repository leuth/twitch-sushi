require 'cgi'
require 'time'

module TwitchSushi::V5
  class Channel
    include TwitchSushi::IdEquality

    attr_reader :id, :broadcaster_language, :created_at, :display_name,
                :email, :follower_amount, :game_name, :language, :logo_url,
                :name, :profile_banner, :profile_banner_background_color,
                :status, :stream_key, :updated_at, :url, :video_banner_url,
                :views

    def initialize(hash, query)
      @query = query
      @id = hash['_id']
      @broadcaster_language = hash['broadcaster_language']
      @created_at = Time.parse(hash['created_at']).utc
      @display_name = hash['display_name']
      @email = hash['email']
      @follower_amount = hash['followers']
      @game_name = hash['game']
      @language = hash['language']
      @logo_url = hash['logo']
      @mature = hash['mature'] || false
      @name = hash['name']
      @partner = hash['partner']
      @profile_banner = hash['profile_banner']
      @profile_banner_background_color = hash['profile_banner_background_color']
      @status = hash['status']
      @stream_key = hash['stream_key']
      @updated_at = Time.parse(hash['updated_at']).utc
      @url = hash['url']
      @video_banner_url = hash['video_banner']
      @views = hash['views']
    end

    def mature?
      @mature
    end

    def partner?
      @partner
    end

    def stream
      @query.streams.get(@name)
    end

    def streaming?
      !stream.nil?
    end

    def user
      @query.users.get(@name)
    end

    def followers(options = {}, &block)
      name = CGI.escape(@id)
      return @query.connection.accumulate(
        :path => "channels/#{id}/follows",
        :json => 'follows',
        :sub_json => 'user',
        :create => -> hash { User.new(hash, @query) },
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end

    def videos(options = {}, &block)
      @query.videos.for_channel(@id, options, &block)
    end
  end

  class Channels
    def initialize(query)
      @query = query
    end

    def get(channel_name)
      name = CGI.escape(channel_name)
      query = { login: name }
      user_json = @query.connection.get('users', query)
      userhash = user_json['users'][0]
      id = userhash['_id']
      TwitchSushi::Status.map(404 => nil, 422 => nil) do
        json = @query.connection.get("channels/#{id}")
        Channel.new(json, @query)
      end
    end
  end
end
