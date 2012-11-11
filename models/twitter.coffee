nTwitter = require('ntwitter')

class Twitter
  constructor: (secrets) ->
    @twitter = new nTwitter(secrets)

  # send `text` in a dm to `users`
  dm: (users, text, callback) ->
    ret = {}
    i = users.length
    for user in users
      do (user) =>
        @post '/direct_messages/new.json', { screen_name: user, text: text }, (err, data) ->
          ret[user] = err ? data
          return callback(null, ret) if --i is 0

  post: (url, data, callback) ->
    @twitter.post(url, data, callback)

module.exports = Twitter
