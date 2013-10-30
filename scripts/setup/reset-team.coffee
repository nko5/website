# removes all setup associated with a team
# BE VERY CAREFUL about calling this, it DELETES EVERYTHING!

async = require('async')
joyent = require('../../config/joyent')
linode = require('../../config/linode')
github = require('../../config/github')

module.exports = resetTeam = (team, next) ->

  removeJoyent = (team, next) ->
    console.log team.slug, 'deleting joyent instance...'
    next(null, team) unless team.machine?.id

    joyent.deleteMachine team.machine.id, (err, res) ->
      return next(err) if err?
      console.log(res)
      console.log team.slug, 'joyent instance deleted!'

      team.ip = null
      team.machine = {}
      team.save (err) -> next(err, team)

  removeDNS = (team, next) ->
    console.log team.slug, 'removing dns entry...'

    linode 'resource.list', (err, res) ->
      return next(err) if err?
      console.log(res)

      # TODO remove team from DNS
      console.log team.slug, 'dns entry removed!'

      next(null, team)

  removeGithubRepo = (team, next) ->
    console.log team.slug, 'deleting github repo...'
    return next(null, team) unless team.slug

    github.del "/repos/nko4/#{team.slug}", (err, res) ->
      return next(err) if err?
      console.log(res)
      console.log team.slug, 'github repo deleted!'

      next(null, team)

  removeGithubTeam = (team, next) ->
    console.log team.slug, 'deleting github team...'
    return next(null, team) unless team.github?.id

    github.del "/teams/#{team.github.id}", (err, res) ->
      return next(err) if err?
      console.log(res)
      console.log team.slug, 'github team deleted!'

      team.github = {}
      team.save (err) -> next(err, team)

  async.waterfall [removeJoyent, removeDNS, removeGithubRepo, removeGithubTeam], next
