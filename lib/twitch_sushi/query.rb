module TwitchSushi::V5
  class Query
    attr_reader :connection, :channels, :streams, :users, :games, :teams, :videos

    def initialize(connection)
      @connection = connection
      @channels = Channels.new(self)
      @streams = Streams.new(self)
      @users = Users.new(self)
      @games = Games.new(self)
      @teams = Teams.new(self)
      @videos = Videos.new(self)
    end
  end
end
