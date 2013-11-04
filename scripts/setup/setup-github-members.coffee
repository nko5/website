async = require('async')
github = require('../../config/github')

module.exports = setupGithubMembers = (options, next) ->
  team = options.team

  async.waterfall [
    (next) ->                 # get people
      console.log team.slug, 'get people'
      team.people next
    (people, next) ->   # add members
      async.forEach people, (person, next) ->
        console.log team.slug, 'add people', person.github.login
        github.put "teams/#{team.github.id}/members/#{person.github.login}", next
      , next
  ], next
