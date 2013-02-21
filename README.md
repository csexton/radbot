# RadBot

To deploy to heroku, run:

    gem install heroku
    heroku create --stack cedar
    git push heroku master
    heroku scale web=0
    heroku scale bot=1

Radbot used to use mongo to keep it's logs, I just used the free MongoLab addon.

RadBot needs to know his enviroment:

    heroku config:add IRC_ENV=production
    heroku config:add IRC_SERVER="irc.freenode.com"
    heroku config:add IRC_CHAN="#arlingtonruby"
    heroku config:add IRC_USER="radbot"
