#! /usr/bin/env ruby

require 'uri'
require 'cinch'
require 'mongo'

MONGO_URI = ENV['MONGOLAB_URI'] || "mongodb://localhost:27017/radbot_development"
$conn = Mongo::Connection.from_uri(MONGO_URI)
$db   = $conn.db(URI.parse(MONGO_URI).path.gsub(/^\//, ''))

$bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.foonetic.net'
    c.user = 'radbot'
    c.nick = 'radbot'
    c.realname = 'RadBot'
    c.channels = ['#radius']
  end

  on :message do |m|
    # Log all the messages to mongo
    $db["channel_#{channel}"].insert({'user' => user, 'message' => message, 'time' => Time.now})
  end

  on :message, "poke" do |m|
    m.reply "Ouch!"
  end
end

$bot.start
