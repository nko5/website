# do everything needed to set up a single team

async = require('async')
mongoose = require('../../models')(require('../../config/env').mongo_url)
Team = mongoose.model 'Team'

setupTeam = (team, next) ->
  # skip empty teams
  return next("Error: #{team} team empty") if team.peopleIds.length is 0

  options = { team: team }
  async.waterfall [
    (next) -> require('./setup-joyent')(options, next),
    (next) -> require('./setup-dns')(options, next),
    (next) -> require('./setup-github')(options, next),
    (next) -> require('./setup-ssh-keys')(options, next),
    (next) -> require('./setup-deploy-key')(options, next),
    (next) -> require('./setup-ubuntu')(options, next)
  ], (err) -> next(err)

if require.main is module
  unless process.env.TEAM
    console.log "Usage: TEAM=organizers coffee #{__filename}"
    process.exit(1)
  slug = process.env.TEAM

  loadTeam = (next) ->
    Team.findOne { slug: slug }, (err, team) ->
      return next(err) if err?
      return next("#{slug} not found") unless team?
      next(null, team)

  resetTeam = (team, next) ->
    # setting RESET=team-slug will DELETE the team's setup
    return next(null, team) unless process.env.RESET is slug
    console.log team.slug, "resetting team..."

    require('./reset-team') team, (err) ->
      return next(err) if err?
      console.log team.slug, "team reset!"
      next(null, team)

  last = (err) ->
    if err
      console.log(err)
      process.exit(1)
    else
      mongoose.connection.close()

  async.waterfall [loadTeam, resetTeam, setupTeam], last