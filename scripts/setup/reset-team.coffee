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
    return next() unless team.joyent?.id
    console.log team.slug, 'deleting joyent instance...'

    joyent.deleteMachine team.joyent.id, (err, res) ->
      return next(err) if err?
      # console.log(res)
      console.log team.slug, 'joyent instance deleted!'

      team.ip = null
      team.joyent = {}
      team.save (err) -> next(err)

  removeDNS = (next) ->
    return next() unless team.linode?.ResourceID
    console.log team.slug, 'removing dns entry...'

    linode 'resource.delete'
      resourceId: team.linode.ResourceID
    , (err, res) ->
      return next(err) if err?
        console.log team.slug, 'dns entry removed!'
        next()

  removeGithubRepo = (next) ->
    console.log team.slug, 'deleting github repo...'

    return next() unless team.slug
    github.del "repos/nko4/#{team.slug}", (err, res, body) ->
      return next(err) if err?
      return next(res.body) unless (res.statusCode is 200) or (res.statusCode is 404)
      # console.log(body)
      console.log team.slug, 'github repo deleted!'

      next()

  removeGithubTeam = (next) ->
    return next() unless team.github?.id
    console.log team.slug, 'deleting github team...'

    github.del "teams/#{team.github.id}", (err, res, body) ->
      return next(err) if err?
      return next(body) unless (res.statusCode is 200) or (res.statusCode is 404)
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

  async.waterfall [removeJoyent, removeDNS, removeGithubRepo, removeGithubTeam, removeDeployKeys, removeRepo], (err) -> next(err)
