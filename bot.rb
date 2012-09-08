#! /usr/bin/env ruby

require 'uri'
require 'cinch'
require 'mongo'
require 'open-uri'
require 'json'

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

  #
  # Lol Plugin
  #
  on :message, /\blol\b|\blolz\b/i do |m|
    images = [
      "http://i.imgur.com/PgP44.png",
      "http://i.imgur.com/n1xml.png"
    ]
    m.reply images.sample
  end

  #
  # Stock Plugin
  #
  on :message, /stock (.*)/i do |m,ticker|
    if ticker
      time ||= '1d'
      m.reply "http://chart.finance.yahoo.com/z?s=#{ticker}&t=1d&q=l&l=on&z=l&a=v&p=s&lang=en-US&region=US#.png"
    else
      m.reply 'Huh?'
    end
  end

  #
  # Haters Plugin
  #
  on :message, /.*hater(z|s)?.*/i do |m|
    images = [
      "http://i.imgur.com/XaZRf.gif",
      #"http://i.imgur.com/oxLDK.gif",
      #"http://i.imgur.com/WN8Ud.gif",
      "http://i.imgur.com/B0ehW.gif",
      "http://i.imgur.com/6oPAO.gif",
      "http://i.imgur.com/0X1AK.png",
      "http://i.imgur.com/FPIUh.png",
      "http://i.imgur.com/296IJ.gif",
      "http://i.imgur.com/Kpx68.jpg"
    ]
    m.reply images.sample
  end

  #
  # Coffee Plugin
  #
  on :message, /.*coffee.*/ do |m|
    message = [
      [:reply, "Hey guys, I like coffee!"],
      [:reply, "Yay!"],
      [:reply, "Coffee!"],
      [:reply, "Coffee? I hope you don't mean Coffeescript! It is a nice option, but don't make it the default."],
      [:action, "smiles"],
      [:action, "is happy"],
      [:action, "dances a *really* fast jig"]
    ]
    msg = message.sample
    if msg.first == :action
      m.channel.action msg.last
    else
      m.reply msg.last
    end
  end

  #
  # Cheer me up Plugin
  #
  on :message, /cheer me up/i do |m|
    images = JSON(open("http://imgur.com/r/aww.json").read)['gallery']
    image = images[rand(images.length)]
    m.reply "http://i.imgur.com/#{image['hash']}#{image['ext']}"
  end
end

$bot.start
