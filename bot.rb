#! /usr/bin/env ruby

require 'cinch'

$bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.foonetic.net'
    c.user = 'radbot'
    c.nick = 'radius'
    c.realname = 'RadBot'
    c.channels = ['#radius']
  end

  on :message, "poke" do |m|
    m.reply "Ouch!"
  end
end

$bot.start
