require 'colors'
env = require '../config/env'
mongoose = require('../models')(env.mongo_url)
async = require 'async'
request = require 'request'

Team = mongoose.model 'Team'

checkTeam = (team, callback) ->
  url = team.entry.url
  request url, (err, res, body) ->
    return callback(err) if err

    status = if res.statusCode is 200
        "#{res.statusCode}".green
      else
        "#{res.statusCode}".red
    console.log("#{status}: #{url}")

    callback(null, { team: team, status: res.statusCode })

downTeams = (teams, callback) ->
  async.map teams, checkTeam, (err, teams) ->
    return callback(err) if err
    down = (team for { team, status } in teams when status isnt 200)
    callback null, down

doubleDownTeams = (teams, callback) ->
  console.log("-- first check --".magenta)
  downTeams teams, (err, down) ->
    return callback(err) if err
    # double check the down ones
    console.log("-- secnond check --".magenta)
    downTeams down, callback

notify = (team, callback) ->
  team.people (err, people) ->
    return callback(err) if err

    emails = for { name, email } in people when /@/.test(email)
      email = email.replace(/\.nodeknockout\.com$/, '')
      if name
        "\"#{name}\" <#{email}>"
      else
        "<#{email}>"

    console.log """
      #{"---".magenta}
      #{team.entry.url}
      http://nodeknockout.com/teams/#{team}/edit

      #{emails.join(", ")}

      Node Knockout Entry Down

      Hi team #{team.name},

      I noticed your app (#{team.entry.url}) was down, so I've removed it from voting.

      If this was an error, and you get it working again, you can turn voting back on at: http://nodeknockout.com/teams/#{team}#votable

      Let me know if you have any questions or concerns.

      Thanks,
      Gerad
      """
    callback()

exit = (err) ->
  mongoose.connection.close()
  throw err if err
  process.exit()

Team.find { 'entry.votable': true, 'entry.url': /./ }, (err, teams) ->
  exit(err) if err
  doubleDownTeams teams, (err, down) ->
    exit(err) if err
    async.forEach down, notify, exit
