# removes all setup associated with a team
# BE VERY CAREFUL about calling this, it DELETES EVERYTHING!

async = require('async')
joyent = require('../../config/joyent')
linode = require('../../config/linode')
github = require('../../config/github')
exec = require('child_process').exec

path = require('path')
reposDir = path.join(__dirname, '..', '..', 'repos')

module.exports = resetTeam = (team, next) ->

  team.setup ?= {}
  team.setup.done ?= {}

  removeKnownHost = (next) ->
    return next() unless team.ip
    console.log team.slug, 'removing ip from known hosts'
    pattern = team.ip.replace(/\./g, '\\.')
    exec "sed -i '' '/#{pattern}/d' ~/.ssh/known_hosts", (err) -> next(err)

  removeJoyent = (next) ->
    return next() unless team.joyent?.id
    console.log team.slug, 'deleting joyent instance...'

    joyent.deleteMachine team.joyent.id, (err, res) ->
      return next(err) if err?

      team.ip = null
      machine = team.joyent

      team.joyent = {}
      team.setup.done['joyent'] = false
      team.setup.done['ssh-keys'] = false
      team.setup.done['ubuntu'] = false
      team.setup.done['deploy'] = false

      team.save (err) -> next(err, machine)

  waitUntilJoyentRemoved = (machine, next) ->
    return next() unless machine?.id
    console.log team.slug, 'wait until instance deleted'

    secs = 15
    i = 0

    do check = ->
      joyent.getMachine machine, (err, res) ->
        if 400 <= err?.statusCode < 500
          console.log team.slug, 'joyent instance deleted!'
          return next()
        return next(err) if err
        switch res.state
          when 'running', 'provisioning', 'stopping', 'stopped', 'deleted'
            console.log team.slug, "#{res.state} (#{i * secs}s)..."
            setTimeout check, secs * 1000
            i += 1
          else
            return next("#{machine.name} in unexpected state: '#{res.state}'")

  removeDNS = (next) ->
    return next() unless team.linode?.ResourceID
    console.log team.slug, 'removing dns entry...'

    linode 'resource.delete',
      resourceId: team.linode.ResourceID
    , (err, res) ->
      return next(err) if err?
      console.log team.slug, 'dns entry removed!'

      team.linode = {}
      team.setup.done['dns'] = false

      team.save (err) -> next(err)

  removeGithubRepo = (next) ->
    console.log team.slug, 'deleting github repo...'

    return next() unless team.slug
    github.del "repos/nko4/#{team.slug}", (err, res, body) ->
      return next(err) if err?
      return next(res.body ? res.statusCode) unless (res.statusCode is 204) or (res.statusCode is 404)
      # console.log(body)
      console.log team.slug, 'github repo deleted!'

      next()

  removeGithubTeam = (next) ->
    return next() unless team.github?.id
    console.log team.slug, 'deleting github team...'

    github.del "teams/#{team.github.id}", (err, res, body) ->
      return next(err) if err?
      return next(body ? res.statusCode) unless (res.statusCode is 204) or (res.statusCode is 404)
      # console.log(body)
      console.log team.slug, 'github team deleted!'

      team.github = {}
      team.setup.done['github'] = false
      team.setup.done['github-members'] = false
      team.setup.done['repo'] = false

      team.save (err) -> next(err)

  removeDeployKeys = (next) ->
    if team.deployKey?.public
      team.deployKey.public = null
      team.deployKey.private = null

    team.setup.done['deploy-key'] = false

    team.save (err) -> next(err)

  removeRepo = (next) ->
    exec "rm -rf ./#{team.slug}", cwd: reposDir, (err) -> next(err)

  removeSetup = (next) ->
    team.setup.status = null
    team.setup.log = null
    team.setup.done = null
    team.save (err) -> next(err)

  async.waterfall [removeKnownHost, removeJoyent, waitUntilJoyentRemoved, removeDNS, removeGithubRepo, removeGithubTeam, removeDeployKeys, removeRepo, removeSetup], (err) -> next(err)

if require.main is module
  slug = process.argv[2]
  unless slug
    console.log "Usage: coffee reset-team.coffee <team-slug>"
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

  async.waterfall [loadTeam, resetTeam], last
