# do everything needed to set up a single team
setupTeam = (options, next) ->
  team = options.team
  githubAuth = options.githubAuth

  # skip empty teams
  return next("Error: #{team} team empty") if team.peopleIds.length is 0

  async = require('async')
  async.waterfall [
    (next) -> require('./setup-joyent')(options, next),
    (next) -> require('./setup-dns')(options, next),
    (next) -> require('./setup-github')(options, next),
    (next) -> require('./setup-ssh-keys')(options, next),
    (next) -> require('./setup-deploy-key')(options, next),
    (next) -> require('./setup-ubuntu')(options, next)
  ], next


if require.main is module
  unless process.env.GITHUB_AUTH and process.env.TEAM
    console.log "Usage: GITHUB_AUTH=[github username]:[password] TEAM=organizers coffee #{__filename}"
    process.exit(1)

  [ghusername, ghpassword] = process.env.GITHUB_AUTH.split(':')
  slug = process.env.TEAM

  mongoose = require('../../models')(require('../../config/env').mongo_url)
  Team = mongoose.model 'Team'
  Team.findOne { slug: slug }, (err, team) ->
    return last(err) if err?
    return last("#{slug} not found") unless team?

    setupTeam
      team: team
      githubAuth:
        username: ghusername
        password: ghpassword
    , last

  last = (err) ->
    if err
      console.log(err)
      process.exit(1)
    else
      mongoose.connection.close()
