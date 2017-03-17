require 'slack-ruby-bot'
require './lib/seal.rb'

module SlackBot
  class SlackListener < SlackRubyBot::Bot
    match /:pr:/ do |client, data, match|
      Seal.new(team: pr_team(data.channel)).update(channel: data.channel)
    end

    match /:percy:/ do |client, data, match|
      Seal.new(team: 'Developers').update_percy(channel: data.channel)
    end

    def self.pr_team(channel)
      case channel
      when ENV['ENGINEERING_CHANNEL_ID']
        'Engineers'
      when ENV['FRONTEND_CHANNEL_ID']
        'Frontend'
      end
    end
  end
end
