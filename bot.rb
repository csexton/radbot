#! /usr/bin/env ruby

require 'uri'
require 'cinch'
require 'mongo'
require 'open-uri'
require 'json'
require './plugins/cleverbot'

ENV["MONGODB_URI"] ||= ENV['MONGOLAB_URI'] || "mongodb://localhost:27017/radbot_development"

# Mongo ruby adapter will use MONGODB_URI env var for connection string
$conn = Mongo::Connection.new
$db   = $conn.db if $conn

$bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.radiusnetworks.com'
    c.user = 'radbot'
    c.nick = 'radbot'
    c.realname = 'RadBot'
    c.password = ENV['IRC_PASS']
    c.channels = ['#radius']
    #c.channels = ['#devradius']
    c.plugins.plugins = [Cinch::Plugins::CleverBot]
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


  on :message, /radbot say:(.*)/i do |m,message|
    $bot.channels.each do |c|
      c.send(message)
    end
  end

  on :message, /radbot say (.*):(.*)/i do |m,channel,message|
    $bot.channels.each do |c|
      if c == channel
        c.send(message)
        ret = "Said #{message} on #{c}"
      end
    end
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
      "http://i.imgur.com/imPCK.gif",
      "http://i.imgur.com/kaIiQ.jpg",
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
  on :message, /cheer (.*?) up/i do |m, n|
    images = JSON(open("http://imgur.com/r/aww.json").read)['data']
    image = images[rand(images.length)]
    m.reply "http://i.imgur.com/#{image['hash']}#{image['ext']}"
    unless n == "me" || n == "you"
      m.reply "I hope that makes #{n} feel better"
    end
  end

  #
  # Illogical
  #
  on :message, /.*(illogical).*/i do |m|
    message = [
      "http://www.katzy.dsl.pipex.com/Smileys/illogical.gif",
      "http://icanhascheezburger.files.wordpress.com/2010/08/e95f76c6-469b-486e-9d18-b2c600ff7ab6.jpg",
      "http://fc01.deviantart.net/fs46/i/2009/191/d/6/Spock_Finds_You_Illogical_by_densethemoose.jpg",
      "http://cache.io9.com/assets/images/8/2008/11/medium_vulcan-cat-is-logical.jpg",
      "http://roflrazzi.files.wordpress.com/2011/01/funny-celebrity-pictures-karaoke.jpg",
      "http://i13.photobucket.com/albums/a292/macota/MCCOYGOBLET.jpg",
      "http://spike.mtvnimages.com/images/import/blog//1/8/7/5/1875583/200905/1242167094687.jpg",
      "http://randomoverload.com/wp-content/uploads/2010/12/fc5558bae4issors.jpg.jpg"
    ]
    m.reply message.sample
  end

  #
  # Gravity Falls Plugin
  #
  on :message, /.*(puke).*/i do |m|
    m.reply "http://i.imgur.com/G0Z36.gif"
  end
  on :message, /.*(attack).*/i do |m|
    m.reply "http://i.imgur.com/xXsO4.gif"
  end
  on :message, /.*(legal).*/i do |m|
    m.reply "http://i.imgur.com/Kmulu.gif"
  end

  on :message, /.*(snuggle).*/i do |m|
    m.reply "http://i.imgur.com/TaWjH.gif"
  end
  on :message, /.*(whee).*/i do |m|
    message = [
      "http://i.imgur.com/ZwzU3.gif",
      "http://i.imgur.com/QAJlS.gif",
      "http://i.imgur.com/zTIPM.gif",
      "http://i.imgur.com/Ovato.gif",
      "shh, please"
    ]
    m.reply message.sample
  end


  #
  #
  #
  on :message, /.*(i hate).*/i do |m|
    m.reply "http://i.imgur.com/ZrN7c.jpg"
  end


  #
  # Is up plugin
  #
  on :message, /is (.*?) (up|down)(\?)?/i do |m, domain|
    body = open("http://www.isup.me/"+domain).read
    if body.include? "It's just you"
      m.reply "#{domain} looks UP from here."
    elsif body.include? "It's not just you!"
      m.reply "#{domain} looks DOWN from here."
    else
      m.reply  "Not sure, #{domain} returned an error."
    end
  end


end

$bot.start
