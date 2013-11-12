require 'colors'
env = require '../config/env'
mongoose = require('../models')(env.mongo_url)
util = require 'util'
postageapp = require('postageapp')(env.secrets.postageapp)
_ = require('underscore')
async = require('async')

Vote = mongoose.model 'Vote'
Person = mongoose.model 'Person'

nag = (judge, callback) ->
  Vote.count { personId: judge.id }, (err, count) ->
    return callback(err) if err

    email = judge.email.replace(/\.nodeknockout\.com$/, '')

    alreadySent = _.include([
      # redacted
    ], email)

    if !alreadySent and count is 0
      util.log "Sending 'judge_nag_one' to '#{email}' (#{count})".yellow
      postageapp.sendMessage
        recipients: email,
        template: 'judge_nag_one'
        variables:
          first_name: judge.name.split(/\s/)[0]
        , (args...) ->
          # console.log "completed sending"
          # console.log args
          # callback(args...)
          callback()
    else
      util.log "Skipping '#{email}' (#{count})"
      callback()

Person.find { role: 'judge', email: /@/ }, (err, judges) ->
  throw err if err

  async.forEachSeries judges, nag, (err) ->
    util.error(err) if err
    mongoose.connection.close()
