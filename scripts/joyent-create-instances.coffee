mongoose = require('../models')(require('../config/env').mongo_url)
#require('../lib/mongo-log')(mongoose.mongo)

spawn = require('child_process').spawn
async = require 'async'
request = require 'request'
joyent = require '../config/joyent'

Team = mongoose.model 'Team'
Person = mongoose.model 'Person'

###
joyent.listImages (err, res) ->
  console.dir(res)
###

###
joyent.listPackages (err, res) ->
  console.dir(res)
###

setupJoyent = (team, next) ->
  # skip empty teams
  return next("Error: #{team} team empty") if team.peopleIds.length is 0

  createMachine = (next) ->
    console.log "Creating machine for #{team}"
    joyent.createMachine
      name: team.toString()
      image: 'd2ba0f30-bbe8-11e2-a9a2-6bc116856d85'
      package: 'ccc8a93a-d5be-4c3c-b199-b39546886538'
    , next

  waitUntilRunning = (machine, next) ->
    secs = 15
    console.log("Waiting until #{machine.name} is running")
    i = 0
    do check = ->
      joyent.getMachine machine, (err, res) ->
        return next(err) if err

        switch res.state
          when 'initializing', 'provisioning'
            console.log("#{machine.name} #{res.state} (#{i * secs}s)...")
            setTimeout check, secs * 1000
            i += 1
          when 'running'
            console.log("#{machine.name} is running!")
            return next(null, machine)
          else
            return next("Error: #{machine.name} in unexpected state: '#{res.state}'")

  logMachine = (machine, next) ->
    console.dir(machine)
    next()

  async.waterfall [createMachine, waitUntilRunning, logMachine], next

Team.find { slug: 'organizers' }, (err, teams) ->
  throw err if err
  async.forEachSeries teams, setupJoyent, (err) ->
    throw err if err
    mongoose.connection.close()
