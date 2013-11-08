require 'colors'
env = require '../config/env'
mongoose = require('../models')(env.mongo_url)

Person = mongoose.model 'Person'

console.log "name\temail"
Person.find { role: 'contestant'}, (err, contestants) ->
  throw err if err
  i = contestants.length
  contestants.forEach (contestant) ->
    console.log "#{contestant.name ? ""}\t#{contestant.email.replace(/\.nodeknockout\.com$/, '')}"
    mongoose.connection.close() if --i is 0
