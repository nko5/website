# creates a deploy key on the team's joyent box and adds it to the team's
# github repo

github = require('../../config/github')
exec = require('child_process').exec
async = require 'async'

module.exports = setupDeployKey = (options, next) ->
  team = options.team

  if team.deployKey.private
    console.log team.slug, 'deploy key already created'
    return next()

  execssh = (cmd, next) ->
    exec "ssh root@#{team.ip} #{cmd}", cwd: __dirname, next

  createDeployKey = (next) ->
    console.log team.slug, 'create deploy key'
    execssh "bash -s < ./setup-deploy-key.sh", (err, stdout, stderr) ->
      next(err) if err?
      next()

  getDeployPublicKey = (next) ->
    console.log team.slug, 'get deploy public key'

    execssh "'cat ~/.ssh/id_deploy.pub'", (err, publicKey, stderr) ->
      return next(err) if err?
      team.deployKey.public = publicKey
      next()

  getDeployPrivateKey = (next) ->
    console.log team.slug, 'get deploy private key'

    execssh "'cat ~/.ssh/id_deploy'", (err, privateKey, stderr) ->
      return next(err) if err?
      team.deployKey.private = privateKey
      next()

  addDeployKeyToGithub = (next) ->
    console.log team.slug, 'add deploy key to github'
    github.post "repos/nko4/#{team.slug}/keys",
      title: "deploy@#{team.slug}.2013.nodeknockout.com"
      key: team.deployKey.public
    , (err) -> next(err)

  saveDeployKeypair = (next) ->
    console.log team.slug, 'save deploy keypair'
    team.save (err) -> next(err)

  async.waterfall [ createDeployKey, getDeployPublicKey, getDeployPrivateKey, addDeployKeyToGithub, saveDeployKeypair ], (err) -> next(err)
