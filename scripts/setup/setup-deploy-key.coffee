# creates a deploy key on the team's joyent box and adds it to the team's
# github repo

github = require('../../config/github')
exec = require('child_process').exec
async = require 'async'
path = require 'path'
fs = require('fs')

rootDir = path.join(__dirname, '..', '..')

module.exports = setupDeployKey = (options, next) ->
  team = options.team

  if team.deployKey.private
    console.log team.slug, 'deploy key already created'
    return next()

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
    github.post "repos/nko5/#{team.slug}/keys",
      title: "deploy@#{team.slug}.2015.nodeknockout.com"
      key: team.deployKey.public
    , (err, res, body) ->
      return next(err) if err
      return next(body ? res.statusCode) unless (res.statusCode is 201)
      next()

  addDeployKeyToRepo = (next) ->
    console.log team.slug, 'add deploy key to repo'
    repoDir = path.join(rootDir, 'repos', team.slug)
    exec "mkdir -p '#{repoDir}'", (err) ->
      return next(err) if err
      try
        fs.writeFileSync(path.join(repoDir, 'id_deploy'), team.deployKey.private)
        fs.writeFileSync(path.join(repoDir, 'id_deploy.pub'), team.deployKey.public)
      catch err
        return next(err)
      next()

  saveDeployKeypair = (next) ->
    console.log team.slug, 'save deploy keypair'
    team.save (err) -> next(err)

  execssh = (cmd, next) ->
    id_nko5 = path.join(rootDir, 'id_nko5')
    exec "ssh -i #{id_nko5} root@#{team.ip} #{cmd}", cwd: __dirname, next

  async.waterfall [ createDeployKey, getDeployPublicKey, getDeployPrivateKey, addDeployKeyToGithub, addDeployKeyToRepo, saveDeployKeypair ], (err) -> next(err)
