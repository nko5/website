# installs public keys from github as authorized_keys on the teams server

github = require('../../config/github')
spawn = require('child_process').spawn
async = require 'async'
isArray = require('util').isArray
path = require('path')

rootDir = path.join(__dirname, '..', '..')

module.exports = setupSSHKeys = (options, next) ->
  team = options.team

  getGithubLogins = (next) ->
    console.log team.slug, 'getting github logins'
    team.people (err, people) ->
      return next(err) if err?
      logins = (p.github.login for p in people when p?.github?.login)

      if logins.length is 0
        return next("Error: #{team} team has no github logins")
      next(null, logins)

  getGithubSSHKeys = (logins, next) ->
    console.log team.slug, 'getting ssh keys'
    keys = {}
    async.each logins, (login, next) ->
      github "users/#{login}/keys", (err, res, body) ->
        return next(err) if err?
        return next(Error(JSON.stringify(body))) unless isArray(body)
        return next(Error(JSON.stringify(body))) if body.length && !body[0].key

        if body.length is 0
          console.warn team, login, 'has no keys'
        else
          keys[login] = (key for {key} in body)
        next()
    , (err) -> next(err, keys)

  createAuthorizedKeys = (loginKeys, next) ->
    console.log team.slug, 'creating authorized keys file'
    keyString = ''
    for login, keys of loginKeys
      keyString += """\n
        ### BEGIN #{login} SSH KEYS (see https://github.com/#{login}.keys)
        #{keys.join('\n')}
        ### END #{login} SSH KEYS\n
      """
    return next("#{team} has no ssh keys") unless keyString
    next(null, keyString)

  addAuthorizedKeysToRoot = (authorizedKeys, next) ->
    console.log team.slug, 'appending to authorized keys file'

    ssh = spawnssh "cat /dev/stdin >> ~/.ssh/authorized_keys",
      stdio: [null, process.stdout, process.stderr],
      next

    ssh.stdin.write(authorizedKeys)
    ssh.stdin.end()

  copyAuthorizedKeysToDeploy = (next) ->
    console.log team.slug, 'copying authorized keys to deploy user'
    cmd = """
      cp ~/.ssh/authorized_keys /home/deploy/.ssh/authorized_keys
      chown deploy /home/deploy/.ssh/authorized_keys
    """.split("\n").join(' && ')
    spawnssh cmd, next

  spawnssh = (cmd, opts, next)->
    unless next
      next = opts
      opts = {}

    opts.stdio ?= 'inherit'

    id_nko5 = path.join(rootDir, 'id_nko5')
    login = "root@#{team.ip}"

    ssh = spawn "ssh", ['-i', id_nko5, login, cmd], opts
    ssh.on 'error', (err) -> next(err)
    ssh.on 'exit', (err) -> next(err)
    ssh

  async.waterfall [getGithubLogins, getGithubSSHKeys, createAuthorizedKeys, addAuthorizedKeysToRoot, copyAuthorizedKeysToDeploy], (err) -> next(err)
