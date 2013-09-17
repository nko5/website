Twit = require('twit')

class Twitter
  constructor: (secrets) ->
    @twitter = new Twit(secrets)

  # send `text` in a dm to `users`
  dm: (users, text, callback) ->
    ret = {}
    i = users.length

    return callback(null, ret) if i is 0

    for user in users
      do (user) =>
        @post '/direct_messages/new.json', { screen_name: user, text: text }, (err, data) ->
          ret[user] = err ? data
          return callback(null, ret) if --i is 0

  post: (url, data, callback) ->
    @twitter.post(url, data, callback)

  get: (url, data, callback) ->
    @twitter.get(url, data, callback)

module.exports = Twitter
