util = require 'util'
app = require '../config/app'
Team = app.db.model 'Team'

message = ->
  messages = [
    'psst, a judge is checking out your app'
    'your page is being attacked, erm judged'
    'batten down the hatches, a judge is coming'
    'come quick! a judge is on the way'
    'the judge has entered the building, erm your app'
    'come and play, you\'re being judged'
    'judge dread? oh noes! your app is being judged'
  ]
  messages[Math.floor(Math.random() * messages.length)]

# notify teams when a judge visits
app.post '/notify', (req, res, next) ->
  # only notify during voting
  return res.send(200) unless app.enabled('voting')

  # only notify when judges click through
  return res.send(200) unless req.user?.judge

  # see if the url being clicked belongs to a team entry
  url = req.body.url
  Team.findOne 'entry.url': req.body.url, (err, team) ->
    return next(err) if err
    return res.send(200) if not team

    # save when the judge viewed the entry
    team.judgeVisitedAt = new Date
    team.save (err, saved) ->
      return next(err) if err

      app.events.emit 'judgeVisit', team

      # if the url doesn't belong to team, or the team is does not have alerts
      # enabled, just ignore it
      return res.send(200) unless team.entry?.alert

      # load the twitter handles for the team
      team.twitterScreenNames (err, handles) ->
        return next(err) if err

        util.log("NOTIFY #{team} (#{handles.join(', ')})".magenta)

        # DM the team with the message
        app.twitter.dm handles, "#{message()} - join at #{url}", (err, result) ->
          return next(err) if err
          console.dir(result)
          res.send(200)
