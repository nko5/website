mongoose = require('../models')(require('../config/env').mongo_url)
#require('../lib/mongo-log')(mongoose.mongo)

spawn = require('child_process').spawn

async = require 'async'
request = require 'request'

Team = mongoose.model 'Team'

setupSSHKeys = (team, next) ->
  # skip empty teams
  return next("Error: #{team} team empty") if team.peopleIds.length is 0

  getGithubLogins = (next) ->
    console.log team.slug, 'getting github logins'
    team.people (err, people) ->
      return next(err) if err?
      logins = (github.login for { github } in people when github?.login)

      if logins.length is 0
        return next("Error: #{team} team has no github logins")

      next(null, logins)

  addSSHKeys = (logins, next) ->
    console.log team.slug, 'adding ssh keys'
    cmd = """
      for u in #{logins.join(' ')}; do
        (
          echo;
          echo "### BEGIN ${u} KEYS (see https://github.com/${u}.keys)";
          wget -qO- "https://github.com/${u}.keys";
          echo;
          echo "### END ${u} KEYS"
        ) >> ~/.ssh/authorized_keys;
      done
    """.replace(/\n\s*/g, ' ')
    login = "root@#{team.slug}.2013.nodeknockout.com"

    ssh = spawn "ssh", [login, cmd] 

    ssh.stdout.on 'data', (s) -> console.log s.toString()
    ssh.stderr.on 'data', (s) -> console.log s.toString()
    ssh.on 'error', next
    ssh.on 'exit', next

  async.waterfall [getGithubLogins, addSSHKeys], next

Team.find { slug: 'organizers' }, (err, teams) ->
  return last(err) if err
  async.forEachSeries teams, setupSSHKeys, last

last = (err) ->
  if err
    console.log(err)
    process.exit(1)
  else
    mongoose.connection.close()
