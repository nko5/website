require 'colors'
env = require '../config/env'
mongoose = require('../models')(env.mongo_url)
util = require 'util'
_ = require('underscore')
async = require('async')

Vote = mongoose.model 'Vote'
Person = mongoose.model 'Person'

nag = (judge, callback) ->
  Vote.count { personId: judge.id }, (err, count) ->
    return callback(err) if err

    email = judge.email

    if count is 0
      util.log "Not voted: '#{email}' (#{count})".yellow
      callback()
    else
      util.log "Has voted: '#{email}' (#{count})"
      callback()

Person.find { role: 'judge', email: /@/ }, (err, judges) ->
  throw err if err

  async.forEachSeries judges, nag, (err) ->
    util.error(err) if err
    mongoose.connection.close()
