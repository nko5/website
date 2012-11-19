require 'colors'
env = require '../config/env'
mongoose = require('../models')(env.mongo_url)

Person = mongoose.model 'Person'

Person.find { email: /@/, }, (err, people) ->
  throw err if err
  for person in people
    console.log person.email.replace(/\.nodeknockout\.com$/, '')
  mongoose.connection.close()
