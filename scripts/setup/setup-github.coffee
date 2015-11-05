# initialize a github repo for a single team

github = require('../../config/github')
spawn = require('child_process').spawn
async = require 'async'
path = require 'path'

rootDir = path.join(__dirname, '..', '..')

module.exports = setupGitHub = (options, next) ->
  team = options.team

  if team.github?.id
    console.log team.slug, 'github already setup!'
    return next()

  async.waterfall [
    (next) ->                 # create repo
      console.log team.slug, 'create repo'
      github.post 'orgs/nko5/repos',
        name: team.slug
        homepage: "http://www.nodeknockout.com/teams/#{team}"
        private: true
      , next
    (res, body, next) ->      # create push hook
      return next(Error(JSON.stringify(body))) unless body.id

      console.log team.slug, 'create hook'
      github.post "repos/nko5/#{team.slug}/hooks",
        name: 'web'
        active: true
        config:
          url: "http://www.nodeknockout.com/teams/#{team.code}/commits"
          content_type: 'json'
      , next
    (res, body, next) ->      # create team
      return next(Error(JSON.stringify(body))) unless body.id

      console.log team.slug, 'create team'
      github.post 'orgs/nko5/teams',
        name: team.name
        repo_names: [ "nko5/#{team.slug}" ]
        permission: 'admin'
      , next
    (res, body, next) ->      # save team
      return next(Error(JSON.stringify(body))) unless body.id

      console.log team.slug, 'set github info'
      team.github = body
      team.save (err) -> next(err)
  ], (err) -> next(err)
