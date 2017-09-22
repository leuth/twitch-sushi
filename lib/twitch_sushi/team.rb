require 'cgi'
require 'time'

module TwitchSushi::V5
  class Team
    include TwitchSushi::IdEquality

    attr_reader :id, :background_url, :banner_url, :created_at, :display_name,
                :info, :logo_url, :name, :updated_at, :url

    def initialize(hash)
      @id = hash['_id']
      @background_url = hash['background']
      @banner_url = hash['banner']
      @created_at = Time.parse(hash['created_at']).utc
      @display_name = hash['display_name']
      @info = hash['info']
      @logo_url = hash['logo']
      @name = hash['name']
      @updated_at = Time.parse(hash['updated_at']).utc
      name = CGI.escape(@name)
      @url = "http://www.twitch.tv/team/#{name}"
    end
  end

  class Teams
    def initialize(query)
      @query = query
    end

    def get(team_name)
      name = CGI.escape(team_name)
      TwitchSushi::Status.map(404 => nil) do
        json = @query.connection.get("teams/#{name}")
        Team.new(json)
      end
    end

    def all(options = {}, &block)
      return @query.connection.accumulate(
        :path => 'teams',
        :json => 'teams',
        :create => Team,
        :limit => options[:limit],
        :offset => options[:offset],
        &block
      )
    end
  end
end
