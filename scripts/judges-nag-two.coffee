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
  email = judge.email.replace(/\.nodeknockout\.com$/, '')

  alreadySent = _.include([
    # redacted
  ], email)

  if !alreadySent
    util.log "Sending 'judge_nag_two' to '#{email}'".yellow
    postageapp.sendMessage
      recipients: email,
      template: 'judge_nag_two'
      variables:
        first_name: judge.name.split(/\s/)[0]
      , callback
  else
    util.log "Skipping '#{email}'"
    callback()

Person.find { role: 'judge', email: /@/ }, (err, judges) ->
  throw err if err

  async.forEachSeries judges, nag, (err) ->
    util.error(err) if err
    mongoose.connection.close()
