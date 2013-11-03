# do everything needed to set up a single team

async = require('async')

setupTeam = (team, next) ->
  # skip empty teams
  return next("Error: #{team} team empty") if team.peopleIds.length is 0

  options = { team: team }
  async.waterfall [
    (next) -> require('./setup-joyent')(options, next),
    (next) -> require('./setup-dns')(options, next),
    (next) -> require('./setup-deploy-key')(options, next),
    (next) -> require('./setup-github')(options, next),
    (next) -> require('./setup-ssh-keys')(options, next),
    (next) -> require('./setup-ubuntu')(options, next)
  ], (err) -> next(err)

if require.main is module
  slug = process.argv[2]
  unless slug
    console.log "Usage: coffee setup-team.coffee <team-slug>"
    process.exit(1)

  mongoose = require('../../models')(require('../../config/env').mongo_url)
  Team = mongoose.model 'Team'

  loadTeam = (next) ->
    Team.findOne { slug: slug }, (err, team) ->
      return next(err) if err?
      return next("#{slug} not found") unless team?
      next(null, team)

  last = (err) ->
    if err
      console.log(err)
      process.exit(1)
    else
      mongoose.connection.close()

  async.waterfall [loadTeam, setupTeam], last
