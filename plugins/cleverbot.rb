require 'cinch'

module Cinch
  module Plugins
    class CleverBot
      require 'cleverbot'
      include Cinch::Plugin

      match lambda { |m| /^#{m.bot.nick}(,|:|\s)+(.+)/i }, use_prefix: false

      def initialize(*args)
        super

        @cleverbot = Cleverbot::Client.new
      end

      def execute(m, sep, message)
        if message =~ /talk to (\w+) about (\w+)/i
          return m.channel.msg "#{$1}: What do you think of #{$2}?"
        end

        msg_back = @cleverbot.write message
        m.reply msg_back, true
      end

    end
  end
end
