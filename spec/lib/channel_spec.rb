require 'spec_helper'
require 'twitch_sushi'

describe 'Channel' do
    before :each do
      TwitchSushi.configure do |config|
        config.client_id = ENV['TW_CLIENT_ID']
      end
    end

    it '.channels.get' do
      VCR.use_cassette('channels_get') do
        channel = TwitchSushi.channels.get('destiny')
        expect(channel.name).to eq 'destiny'
        expect(channel.game_name).to eq 'League of Legends'
      end
    end
end
