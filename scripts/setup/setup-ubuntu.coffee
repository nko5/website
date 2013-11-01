# gets the team's joyent box deploy ready

spawn = require('child_process').spawn
async = require 'async'
readFileSync = require('fs').readFileSync
path = require('path')

rootDir = path.join(__dirname, '..', '..')

# only read the setup script once
setupScript = readFileSync(path.join(__dirname, './setup-ubuntu.sh'), 'utf8')

module.exports = setupUbuntu = (options, next) ->
  team = options.team

  uploadSetupScript = (next) ->
    console.log team.slug, 'uploading setup script'

    ssh = spawnssh "cat /dev/stdin > ~/setup-ubuntu.sh", next
    ssh.stdin.write(setupScript)
    ssh.stdin.end()

  runSetupScript = (next) ->
    console.log team.slug, 'running setup script'
    spawnssh "bash setup-ubuntu.sh #{team.slug}.2013.nodeknockout.com", next

  runDeploySetupScript = (next) ->
    console.log team.slug, 'running deploy setup'

    setup = spawn './deploy', ['nko', 'setup'],
      cwd: path.join(rootDir, 'repos', team.slug)
      stdio: 'inherit'
    setup.on 'error', (err) -> next(err)
    setup.on 'exit', (err) -> next(err)

  spawnssh = (cmd, next)->
    id_nko4 = path.join(rootDir, 'id_nko4')
    login = "root@#{team.ip}"

    ssh = spawn "ssh", ['-i', id_nko4, login, cmd],
      stdio: ['pipe', process.stdout, process.stderr]
    ssh.on 'error', (err) -> next(err)
    ssh.on 'exit', (err) -> next(err)
    ssh

  async.waterfall [uploadSetupScript, runSetupScript, runDeploySetupScript], (err) -> next(err)
