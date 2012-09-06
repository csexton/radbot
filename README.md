# RadBot

To deploy to heroku, run:

    gem install heroku
    heroku create --stack cedar
    git push heroku master
    heroku scale web=0
    heroku scale bot=1

Radbot needs mongo to keep it's logs, I just use the free MongoLab addon.
