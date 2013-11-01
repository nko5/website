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

  removeJoyent = (next) ->
    return next(null, null) unless team.joyent?.id
    console.log team.slug, 'deleting joyent instance...'

    joyent.deleteMachine team.joyent.id, (err, res) ->
      return next(err) if err?

      team.ip = null
      machine = team.joyent
      team.joyent = {}
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
          when 'running', 'provisioning', 'stopped', 'deleted'
            console.log team.slug, "#{res.state} (#{i * secs}s)"
            setTimeout check, secs * 1000
            i += 1
          else
            return next("#{machine.name} in unexpected state: '#{res.state}'")

  removeDNS = (next) ->
    return next() unless team.linode?.ResourceID
    console.log team.slug, 'removing dns entry...'

    linode 'resource.delete'
      resourceId: team.linode.ResourceID
    , (err, res) ->
      return next(err) if err?
      console.log team.slug, 'dns entry removed!'
      team.linode = {}
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
      team.save (err) -> next(err)

  removeDeployKeys = (next) ->
    if team.deployKey?.public
      team.deployKey.public = null
      team.deployKey.private = null
    team.save (err) -> next(err)

  removeRepo = (next) ->
    exec "rm -rf ./#{team.slug}", cwd: reposDir, (err) -> next(err)

  async.waterfall [removeJoyent, waitUntilJoyentRemoved, removeDNS, removeGithubRepo, removeGithubTeam, removeDeployKeys, removeRepo], (err) -> next(err)
