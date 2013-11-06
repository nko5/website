# do everything needed to set up a single team

async = require('async')

setupTeam = (team, next) ->
  # skip empty teams
  return next("Error: #{team} team empty") if team.peopleIds.length is 0

  team.setup ?= {}
  team.setup.done ?= {}

  async.series [
    (next) -> setup(team, 'joyent', next)
    (next) -> setup(team, 'dns', next)
    (next) -> setup(team, 'ubuntu', next)
    (next) -> setup(team, 'github', next)
    (next) -> setup(team, 'deploy-key', next)
    (next) -> setup(team, 'repo', next)
    (next) -> setup(team, 'github-members', next)
    (next) -> setup(team, 'ssh-keys', next)
    (next) -> setup(team, 'deploy', next)
  ], next

# loads and runs the callback script for the step, along with logging and saving which steps were completed, so those
# steps will not be re-run if the team is setup again
setup = (team, step, next) ->
  console.log team.slug, step, 'start setup'

  if team.setup.done[step]
    console.log team.slug, step, 'already setup'
    return next()

  require("./setup-#{step}") team: team, (err) ->
    return next(err) if err
    console.log team.slug, step, 'finished setup'

    team.setup.done[step] = true
    team.save next

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
