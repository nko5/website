_ = require 'underscore'
m = require './middleware'
rollbar = require('rollbar')

module.exports = (app) ->
  Team = app.db.model 'Team'
  Deploy = app.db.model 'Deploy'

  (req, res, next) ->
    return next() unless app.enabled('coding')
    return next() unless (req.method is 'GET' or req.method is 'POST') and (req._parsedUrl.pathname is '/deploys' or req._parsedUrl.pathname is '/deploy/modulus')

    # custom error handler (since the default one dies w/o session)
    error = (err) ->
      console.error err.toString().red
      res.end JSON.stringify(err)

    try
      req.session.destroy()
    catch err
      return error(err)

    teamcode = req.query.teamcode
    projectId = req.query.project

    if teamcode
      Team.findByCode teamcode, (err, team) ->
        return error(err) if err
        return res.send(404) unless team

        console.log "#{'DEPLOY'.magenta} #{team.name} (#{team.id})"
        attr = _.clone req.query
        attr.teamId = team._id
        attr.remoteAddress = req.socket.remoteAddress
        attr.os = req.query.os
        attr.platform = req.query.release

        rollbar.reportMessage("received deploy hook: #{team.slug} from ip: #{attr.remoteAddress}, platform: #{attr.platform}, os: #{attr.os}")

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
            res.send JSON.stringify(deploy)

    else if projectId
      # TODO: query Team for modulus project id
      rollbar.reportMessage("received modulus deploy: #{projectId}")
