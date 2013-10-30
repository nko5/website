# creates a joyent instance for a single team

async = require 'async'
joyent = require '../../config/joyent'

module.exports = setupJoyent = (options, next) ->
  team = options.team
  image = options.joyent?.image ? 'd2ba0f30-bbe8-11e2-a9a2-6bc116856d85' # ubuntu 12.04 - 64bit v2.4.2
  packg = options.joyent?.package ? 'ec521e7a-8799-4ffc-a914-bb41233f25f5' # 512mb ram - kvm

  # joyent.listImages (err, res) -> console.dir(res)
  # joyent.listPackages (err, res) -> console.dir(res)

  createMachine = (next) ->
    console.log team.slug, 'create machine'
    joyent.createMachine
      name: team.slug
      image: image
      package: packg
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
            console.log team.slug, res.state
            return next(null, res)
          else
            return next("Error: #{machine.name} in unexpected state: '#{res.state}'")

  saveMachine = (machine, next) ->
    console.log team.slug, 'save machine ip'
    team.ip = machine.ips[0]
    team.machine = machine
    team.save next

  async.waterfall [createMachine, waitUntilRunning, saveMachine], next
