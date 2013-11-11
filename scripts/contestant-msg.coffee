require 'colors'
env = require '../config/env'
mongoose = require('../models')(env.mongo_url)
util = require 'util'
postageapp = require('postageapp')(env.secrets.postageapp)
_ = require('underscore')
async = require('async')

Team = mongoose.model 'Team'
Person = mongoose.model 'Person'

currentTeam = null

msgTeam = (team, callback) ->
  currentTeam = team
  currentTeam.people (err, people) ->
    return callback(err) if err
    emailable = (person for person in people when /@/.test(person.email))
    util.log "Sending 'contestant_voting_start' to '#{team.name}'".yellow
    async.forEach emailable, msgPerson, callback

msgPerson = (person, callback) ->
  email = person.email
  name = person.name or person.slug
  firstName = name?.split(/\s+/)[0] ? ''

  address = if name
      "\"#{name}\" <#{email}>"
    else
      email
  util.log "\t -> #{address} (#{firstName})".yellow

  postageapp.sendMessage
    recipients: address
    template: 'contestant_voting_start'
    variables:
      team: " #{currentTeam.name}"
      slug: " #{currentTeam.slug}"
    , (args...) ->
      # console.log "completed sending"
      # console.log args
      # callback(args...)
      callback()

Team.find {}, (err, teams) ->
  throw err if err

  async.forEachSeries teams, msgTeam, (err) ->
    util.error(err) if err
    mongoose.connection.close()
