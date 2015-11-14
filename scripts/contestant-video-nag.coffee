require 'colors'
env = require '../config/env'
mongoose = require('../models')(env.mongo_url)
util = require 'util'
postageapp = require('postageapp')(env.secrets.postageapp)
_ = require('underscore')
async = require('async')

util.log "skipping email (in dev)..."

Team = mongoose.model 'Team'
Person = mongoose.model 'Person'

nagTeam = (team, callback) ->
  team.people (err, people) ->
    return callback(err) if err
    emailable = (person for person in people when /@/.test(person.email))
    util.log "Sending 'contestant_video_nag' to '#{team.name}'".yellow
    async.forEach emailable, nagPerson, callback

nagPerson = (person, callback) ->
  email = person.email.replace(/\.nodeknockout\.com$/, '')
  name = person.name or person.slug
  firstName = name?.split(/\s+/)[0] ? ''

  address = if name
      "\"#{name}\" <#{email}>"
    else
      email
  util.log "\t -> #{address} (#{firstName})".yellow

  if env.skip_emails
    util.log "skipping email (in dev)..."
    callback()
  else
    postageapp.sendMessage
      recipients: address
      template: 'contestant_video_nag'
      variables:
        first_name: " #{firstName}"
      , (args...) ->
        # console.log "completed sending"
        # console.log args
        # callback(args...)
        callback()


Team.find { 'entry.votable': true, 'entry.videoURL':  {$in: ["",null]}}, (err, teams) ->
  throw err if err

  async.forEachSeries teams, nagTeam, (err) ->
    util.error(err) if err
    mongoose.connection.close()
