unless process.env.LOGIN
  console.log "Usage: LOGIN=[github username]:[password] coffee #{__filename}"
  process.exit(1)

mongoose = require('../models')(require('../config/env').mongo_url)
#require('../lib/mongo-log')(mongoose.mongo)

spawn = require('child_process').spawn
async = require 'async'
request = require 'request'

github = (path) -> "https://#{process.env.LOGIN}@api.github.com/#{path}"

Team = mongoose.model 'Team'
Person = mongoose.model 'Person'

createTeam = (team, next) ->
  # skip empty teams
  return next() if team.peopleIds.length is 0

  async.waterfall [
    (next) ->                 # create repo
      console.log team.slug, 'create repo'
      request.post
        url: github 'orgs/nko4/repos'
        json:
          name: team.slug
          homepage: "http://2013.nodeknockout.com/teams/#{team}"
          private: true
      , next
    (res, body, next) ->      # create push hook
      return next(Error(JSON.stringify(body))) unless body.id

      console.log team.slug, 'create hook'
      request.post
        url: github "repos/nko4/#{team.slug}/hooks"
        json:
          name: 'web'
          active: true
          config:
            url: "http://nodeknockout.com/teams/#{team.code}/commits"
            content_type: 'json'
      , next
    (res, body, next) ->      # create team
      return next(Error(JSON.stringify(body))) unless body.id

      console.log team.slug, 'create team'
      request.post
        url: github 'orgs/nko4/teams'
        json:
          name: team.name
          repo_names: [ "nko4/#{team.slug}" ]
          permission: 'admin'
      , next
    (res, body, next) ->      # save team id
      return next(Error(JSON.stringify(body))) unless body.id

      console.log team.slug, 'save github info'
      team.github = body
      team.save next
    (team, n, next) ->        # get people
      console.log team.slug, 'get people'
      Person.find { _id: { $in: team.peopleIds } }, (err, people) ->
        next err, team, people
    (team, people, next) ->   # add members
      async.forEach people, (person, next) ->
        console.log team.slug, 'add people', person.github.login
        request.put
          url: github "teams/#{team.github.id}/members/#{person.github.login}"
          json: {}
        , next
      , next
    (next) ->                 # seed repo
      console.log team.slug, 'seed repo'
      createRepo = spawn './create-repo.sh',
        [ team.slug, team.code, team.name, team.github.id ],
        cwd: __dirname
      createRepo.stdout.on 'data', (s) -> console.log s.toString()
      createRepo.stderr.on 'data', (s) -> console.log s.toString()
      createRepo.on 'exit', -> next()
  ], next

Team.find { 'github.id': null }, (err, teams) ->
  throw err if err
  async.forEachSeries teams, createTeam, (err) ->
    throw err if err
    mongoose.connection.close()
