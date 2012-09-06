#! /usr/bin/env ruby

require 'uri'
require 'cinch'
require 'mongo'

ENV["MONGODB_URI"] ||= ENV['MONGOLAB_URI'] || "mongodb://localhost:27017/radbot_development"

# Mongo ruby adapter will use MONGODB_URI env var for connection string
$conn = Mongo::Connection.new
$db   = $conn.db if $conn

$bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.foonetic.net'
    c.user = 'radbot'
    c.nick = 'radbot'
    c.realname = 'RadBot'
    c.channels = ['#radius']
  end

  on :message do |m|
    if $db
      # Log every message to mongo
      channel = m.channel.to_s.gsub('#', '')
      user = m.user.to_s
      message = m.message.to_s
      $db["channel_#{channel}"].insert({'user' => user, 'message' => message, 'time' => Time.now})
    end
  end

  on :message, "poke" do |m|
    m.reply "Ouch!"
  end

  on :message, /LOL/i do |m|
    images = [
      "http://i.imgur.com/PgP44.png",
      "http://i.imgur.com/n1xml.png"
    ]
    m.reply images.sample
  end

end

$bot.start
