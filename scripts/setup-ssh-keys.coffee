unless process.env.LOGIN
  console.log "Usage: LOGIN=[github username]:[password] coffee #{__filename}"
  process.exit(1)
github = (path) -> "https://#{encodeURIComponent(process.env.LOGIN)}@api.github.com/#{path}"

mongoose = require('../models')(require('../config/env').mongo_url)
#require('../lib/mongo-log')(mongoose.mongo)

spawn = require('child_process').spawn
async = require 'async'
request = require 'request'
isArray = require('util').isArray

Team = mongoose.model 'Team'

setupSSHKeys = (team, next) ->
  # skip empty teams
  return next("Error: #{team} team empty") if team.peopleIds.length is 0

  getGithubLogins = (next) ->
    console.log team.slug, 'getting github logins'
    team.people (err, people) ->
      return next(err) if err?
      logins = (p.github.login for p in people when p?.github?.login)

      if logins.length is 0
        return next("Error: #{team} team has no github logins")

      next(null, logins)

  getGithubSSHKeys = (logins, next) ->
    console.log team.slug, 'getting ssh keys'
    keys = {}
    async.each logins, (login, next) ->
      request
          url: github "users/#{login}/keys"
          json: {}
        , (err, res, body) ->
          return next(err) if err?
          return next(Error(JSON.stringify(body))) unless isArray(body)
          return next(Error(JSON.stringify(body))) if body.length && !body[0].key

          if body.length is 0
            console.warn team, login, 'has no keys'
          else
            keys[login] = (key for {key} in body)
          next()
    , (err) -> next(err, keys)

  createAuthorizedKeys = (loginKeys, next) ->
    console.log team.slug, 'creating authorized keys file'
    keyString = ''
    for login, keys of loginKeys
      keyString += """\n
        ### BEGIN #{login} SSH KEYS (see https://github.com/#{login}.keys)
        #{keys.join('\n')}
        ### END #{login} SSH KEYS\n
      """
    return next("#{team} has no ssh keys") unless keyString
    next(null, keyString)

  addAuthorizedKeys = (authorizedKeys, next) ->
    console.log team.slug, 'appending to authorized keys file'

    login = "root@#{team.slug}.2013.nodeknockout.com"
    cmd = "cat /dev/stdin >> ~/.ssh/authorized_keys"

    ssh = spawn "ssh", [login, cmd] 
    ssh.stdout.on 'data', (s) -> console.log s.toString()
    ssh.stderr.on 'data', (s) -> console.log s.toString()
    ssh.on 'error', next
    ssh.on 'exit', next

    ssh.stdin.write(authorizedKeys)
    ssh.stdin.end()

  async.waterfall [getGithubLogins, getGithubSSHKeys, createAuthorizedKeys, addAuthorizedKeys], next

Team.find { slug: 'organizers' }, (err, teams) ->
  return last(err) if err
  async.forEachSeries teams, setupSSHKeys, last

last = (err) ->
  if err
    console.log(err)
    process.exit(1)
  else
    mongoose.connection.close()
