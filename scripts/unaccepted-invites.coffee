require 'colors'
env = require '../config/env'
mongoose = require('../models')(env.mongo_url)

Team = mongoose.model 'Team'

console.log "team_id\tteam\temail\tcode"

Team.find {"peopleIds": []}, (err, teams) ->
  throw err if err
  i = teams.length
  teams.forEach (team) ->
    team.invites.forEach (invite) ->
      console.log "#{team.id}\t#{team.name ? ""}\t#{invite.email.replace(/\.nodeknockout\.com$/, '')}\t#{invite.code}"
    mongoose.connection.close() if --i is 0
