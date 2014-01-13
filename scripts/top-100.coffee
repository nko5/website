require 'colors'
env = require '../config/env'
mongoose = require('../models')(env.mongo_url)
util = require 'util'
postageapp = require('postageapp')(env.secrets.postageapp)
_ = require('underscore')
async = require('async')

Team = mongoose.model 'Team'
Person = mongoose.model 'Person'

showPerson = (person, callback) ->
  console.log "  #{person.email}"
  callback()

showTeamMembers = (team, callback) ->
  team.people (err, people) ->
    return callback(err) if err
    console.log "Team: #{team.name}"
    async.forEach people, showPerson, callback

Team.top100 (error, teams) ->
  return next error if error

  async.forEachSeries teams, showTeamMembers, (err) ->
    util.error(err) if err
    mongoose.connection.close()
