mongoose = require('../models')(require('../config/env').mongo_url)
#require('../lib/mongo-log')(mongoose.mongo)

spawn = require('child_process').spawn
async = require 'async'
request = require 'request'
joyent = require '../config/joyent'

Team = mongoose.model 'Team'
Person = mongoose.model 'Person'

# joyent.listImages (err, res) -> console.dir(res)
image = 'd2ba0f30-bbe8-11e2-a9a2-6bc116856d85' # ubuntu 12.04 - 64bit v2.4.2
# joyent.listPackages (err, res) -> console.dir(res)
package = 'ec521e7a-8799-4ffc-a914-bb41233f25f5' # 512mb ram - kvm

setupJoyent = (team, next) ->
  # skip empty teams
  return next("Error: #{team} team empty") if team.peopleIds.length is 0

  createMachine = (next) ->
    console.log team.slug, 'create machine'
    joyent.createMachine
      name: team.toString()
      image: image
      package: package
    , next

  waitUntilRunning = (machine, next) ->
    console.log team.slug, 'wait until running'

    secs = 15
    i = 0

    do check = ->
      joyent.getMachine machine, (err, res) ->
        return next(err) if err
        switch res.state
          when 'provisioning'
            console.log team.slug, "#{res.state} (#{i * secs}s)"
            setTimeout check, secs * 1000
            i += 1
          when 'running'
            console.log team.slug, "running"
            return next(null, res)
          else
            return next("Error: #{machine.name} in unexpected state: '#{res.state}'")

  saveMachine = (machine, next) ->
    console.log team.slug, 'save machine ip'
    team.ip = machine.ips[0]
    team.machine = machine
    team.save next

  async.waterfall [createMachine, waitUntilRunning, saveMachine], next

Team.find { slug: 'organizers' }, (err, teams) ->
  throw err if err
  async.forEachSeries teams, setupJoyent, (err) ->
    throw err if err
    mongoose.connection.close()
