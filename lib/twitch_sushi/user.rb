require 'cgi'
require 'time'

module TwitchSushi::V5
  class User
    include TwitchSushi::IdEquality

    attr_reader :id, :bio, :created_at, :display_name, :email, :logo_url, :name,
                :type, :updated_at

    def initialize(hash, query)
      @query = query
      @id = hash['_id']
      @bio = hash['bio']
      @created_at = Time.parse(hash['created_at']).utc
      @display_name = hash['display_name']
      @email = hash['email']
      @email_verified = hash['email_verified']
      @logo_url = hash['logo']
      @name = hash['name']
      @partnered = hash['partnered']
      @twitter_connected = hash['twitter_connected']
      @type = hash['type']
      @updated_at = Time.parse(hash['updated_at']).utc
    end

    def channel
      @query.channels.get(@name)
    end

    def stream
      @query.streams.get(@name)
    end

    def streaming?
      !stream.nil?
    end

    def staff?
      true if @type == 'staff'
      false if @type != 'staff'
    end

    def email_verified?
      @email_verified
    end

    def partnered?
      @partnered
    end

    def twitter_connected?
      @twitter_connected
    end

    def following(options = {}, &block)
      id = CGI.escape(@id)
      return @query.connection.accumulate(
        path: "users/#{id}/follows/channels",
        json: 'follows',
        sub_json: 'channel',
        create: -> hash { Channel.new(hash, @query) },
        limit: options[:limit],
        offset: options[:offset],
        &block
      )
    end

    def following?(target)
      id = target.id
      user_id = CGI.escape(@id)
      channel_id = CGI.escape(id)

      TwitchSushi::Status.map(404 => false) do
        @query.connection.get("users/#{user_id}/follows/channels/#{channel_id}")
        true
      end
    end
  end

  class Users
    def initialize(query)
      @query = query
    end

    def get(user_name)
      name = CGI.escape(user_name)
      query = { login: name }
      user_json = @query.connection.get('users', query)
      userhash = user_json['users'][0]
      id = userhash['_id']
      TwitchSushi::Status.map(404 => nil) do
        json = @query.connection.get("users/#{id}")
        User.new(json, @query)
      end
    end
  end
end
