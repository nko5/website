require 'colors'
env = require '../config/env'
mongoose = require('../models')(env.mongo_url)

Team = mongoose.model 'Team'

Team.updateAllSavedScores (err) ->
  if err
    console.log "Unable to update scores: #{err}"
  else
    console.log "Scores are now updated."
  mongoose.connection.close()
