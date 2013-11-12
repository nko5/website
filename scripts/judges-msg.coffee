require 'colors'
env = require '../config/env'
mongoose = require('../models')(env.mongo_url)
util = require 'util'
postageapp = require('postageapp')(env.secrets.postageapp)
_ = require('underscore')
async = require('async')

Person = mongoose.model 'Person'

welcome = (judge, callback) ->
  email = judge.email
  util.log "Sending 'judge_voting_start' to '#{email}'".yellow
  postageapp.sendMessage
    recipients: email,
    template: 'judge_voting_start'
    variables:
      first_name: judge.name.split(/\s/)[0]
    , (args...) ->
      # console.log "completed sending"
      # console.log args
      # callback(args...)
      callback()

Person.find { role: 'judge', email: /@/ }, (err, judges) ->
  throw err if err

  async.forEachSeries judges, welcome, (err) ->
    util.error(err) if err
    mongoose.connection.close()
