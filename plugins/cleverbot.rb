require 'cinch'

module Cinch
  module Plugins
    class CleverBot
      require 'cleverbot'
      include Cinch::Plugin

      match lambda { |m| /^#{m.bot.nick} (.+)/i }, use_prefix: false

      def initialize(*args)
        super

        @cleverbot = Cleverbot::Client.new
      end

      def execute(m, message)
        msg_back = @cleverbot.write message
        m.reply msg_back, true
      end

    end
  end
end
