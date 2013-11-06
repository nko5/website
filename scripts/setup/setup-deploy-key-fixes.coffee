spawn = require('child_process').spawn
exec = require('child_process').exec
async = require 'async'
path = require 'path'
fs = require('fs')

rootDir = path.join(__dirname, '..', '..')

module.exports = setupDeployKeyFixes = (options, next) ->
  team = options.team

  fixDeployKeyPermissions = (next) ->
    console.log team.slug, 'fix deploy key repo permissions'
    repoDir = path.join(rootDir, 'repos', team.slug)
    exec "chmod 600 '#{repoDir}'/id_deploy*", (err) -> next(err)

  addDeployKeyToDeployUser = (next) ->
    console.log team.slug, 'set up deploy key on deploy user'
    cmd = """
      cp ~/.ssh/id_deploy /home/deploy/.ssh/id_rsa
      cp ~/.ssh/id_deploy.pub /home/deploy/.ssh/id_rsa.pub
      chown deploy /home/deploy/.ssh/id_rsa*
    """.split("\n").join(' && ')

    login = "root@#{team.ip}"
    id_nko4 = path.join(rootDir, 'id_nko4')

    ssh = spawn 'ssh', ['-i', id_nko4, login, cmd], stdio: 'inherit'

    ssh.on 'error', (err) -> next(err)
    ssh.on 'exit', (err) -> next(err)

  async.series [fixDeployKeyPermissions, addDeployKeyToDeployUser], (err) -> next(err)
