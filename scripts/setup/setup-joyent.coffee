# creates a joyent instance for a single team

async = require 'async'
joyent = require '../../config/joyent'
spawn = require('child_process').spawn
path = require 'path'

rootDir = path.join(__dirname, '..', '..')

# joyent.listImages (err, res) -> console.dir(res)
# joyent.listPackages (err, res) -> console.dir(res)

module.exports = setupJoyent = (options, next) ->
  team = options.team
  image = 'd2ba0f30-bbe8-11e2-a9a2-6bc116856d85' # ubuntu 12.04 - 64bit v2.4.2
  packg = '4f262a43-1151-45a0-a29c-e726e878c582' # 512mb ram - kvm

  console.log team.slug, 'setting up joyent...'

  if team.joyent?.id
    console.log team.slug, 'joyent already setup!'
    return next()

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
          when 'provisioning', 'stopped', 'ready'
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
    team.joyent = machine
    team.save (err) -> next(err)

  waitUntilSSH = (next) ->
    console.log team.slug, 'waiting for ssh connection'

    secs = 15

    do check = ->
      ssh = spawn 'ssh', [
        '-o', 'StrictHostKeyChecking=no',
        '-o', 'BatchMode=yes',
        '-i', './id_nko4',
        "root@#{team.ip}",
        "exit"],
        cwd: rootDir,
        stdio: 'inherit'
      ssh.on 'error', next
      ssh.on 'exit', (err) ->
        if err # couldn't open ssh connection
          console.log team.slug, "waiting..."
          setTimeout check, secs * 1000
        else
          next()

  async.waterfall [createMachine, waitUntilRunning, saveMachine, waitUntilSSH], (err) -> next(err)
