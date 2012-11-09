_ = require 'underscore'
m = require './middleware'
util = require 'util'

module.exports = (app) ->
  Team = app.db.model 'Team'
  Deploy = app.db.model 'Deploy'

  (req, res, next) ->
    return next() unless req.method is 'POST' and req.url is '/deploys'
    console.log req.body

    # custom error handler (since the default one dies w/o session)
    error = (err) ->
      util.error err.toString().red
      res.end JSON.stringify(err)

    try
      req.session.destroy()
      slug = req.body.user.replace('nko3-', '')
    catch err
      return error(err)

    Team.findBySlug slug, (err, team) ->
      return error(err) if err
      return res.send(404) unless team

      util.log "#{'DEPLOY'.magenta} #{team.name} (#{team.id})"

      attr = _.clone req.body
      attr.teamId = team.id
      attr.remoteAddress = req.socket.remoteAddress
      attr.hostname = "#{req.body.subdomain}.jitsu.com"

      # save the deploy in the db
      deploy = new Deploy attr
      deploy.save (err, deploy) ->
        return error(err) if err

        # increment overall/team deploy count
        $inc = deploys: 1
        app.stats.increment $inc
        team.incrementStats $inc, (err, team) ->
          return error(err) if err

          app.events.emit 'updateTeamStats', team
          app.events.emit 'deploy', deploy, team

          res.end JSON.stringify(deploy)
