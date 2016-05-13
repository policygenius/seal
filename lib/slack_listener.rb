require 'slack-ruby-bot'
require './lib/seal.rb'

module SlackBot
  class SlackListener < SlackRubyBot::Bot
    match /:pr:/ do |client, data, match|
      Seal.new(team: 'Developers').update(channel: data.channel)
    end

    JSON.parse(ENV['PG_REPOS']).each do |repo|
      command repo do |client, data, match|
        Seal.new(team: 'Developers', repo: repo).update(channel: data.channel)
      end
    end
  end
end
