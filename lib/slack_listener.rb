require 'slack-ruby-bot'
require './lib/seal.rb'

module SlackBot
  class SlackListener < SlackRubyBot::Bot
    match /:pr:/ do |client, data, match|
      Seal.new(team: 'Developers').update(channel: data.channel)
    end

    match /:percy:/ do |client, data, match|
      Seal.new(team: 'Developers').update_percy(channel: data.channel)
    end
  end
end
