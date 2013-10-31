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
    console.log team.slug, 'removing dns entry...'

    linode 'resource.list', (err, res) ->
      return next(err) if err?

      domains = (d for d in res when d.NAME is "#{team.slug}.2013")
      unless domains.length and domains[0].RESOURCEID
        console.log team.slug, 'dns entry not found'
        return next()
      resourceId = domains[0].RESOURCEID

      linode 'resource.delete'
        resourceId: resourceId
      , (err, res) ->
        return next(err) if err?
        console.log team.slug, 'dns entry removed!'
        next()

  removeGithubRepo = (next) ->
    return next() unless team.slug
    return next() # seems like this isn't implemented by github
    console.log team.slug, 'deleting github repo...'

    github.del "repos/nko4/#{team.slug}", (err, res, body) ->
      return next(err) if err?
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

  removeRepo = (next) ->
    exec "rm -rf ./#{team.slug}", cwd: reposDir, (err) -> next(err)

  async.waterfall [removeJoyent, removeDNS, removeGithubRepo, removeGithubTeam, removeRepo], (err) -> next(err)
