_ = require 'underscore'
app = require '../config/app'
m = require './middleware'
Person = app.db.model 'Person'

# index
app.get '/judges', (req, res, next) ->
  if app.enabled('pre-registration') or app.enabled('registration') or app.enabled('pre-coding')
    res.redirect("/judges/new")
  else
    Person.find { role: 'judge' }, (err, judges) ->
      return next err if err

      res.render2 'judges',
        judges: _.shuffle(judges)
        judgesGrouped: _.chain(judges).shuffle().groupBy((a,b) -> Math.floor(b/4)).value()

# start (just redirects to judges/dashboard with twitter login)
app.get '/judges/start', (req, res, next) ->
  judgesDashboardPath = "/judges/dashboard"
  if req.loggedIn
    res.redirect judgesDashboardPath
  else
    res.redirect "/login/twitter?returnTo=#{judgesDashboardPath}"

# judging dashboard
app.get '/judges/dashboard', [m.loadPerson, m.loadPersonTeam, m.loadPersonVotes, m.loadCanSeeVotes], (req, res, next) ->
  if app.enabled('voting') and req.user and (req.user?.admin || req.user?.judge || req.myTeam)
    # pick the next entry for you to judge
    req.user.nextTeam (err, nextTeam) ->
      return next err if err

      if nextTeam
        nextTeam.people (err, people) ->
          res.render2 'judges/dashboard', nextTeam: nextTeam, people: people, votes: req.votes || []
      else
        res.render2 'judges/dashboard', nextTeam: nextTeam, people: [], votes: req.votes || []

  else
    res.redirect("/entries")


app.get '/judges/nominations', (req, res, next) ->
  Person.find { role: 'nomination' }, {}, {sort: [['updatedAt', -1]]}, (err, judges) ->
    return next err if err
    res.render2 'judges', judges: judges

app.get '/judges/technical', (req, res, next) ->
  Person.find { role: 'judge', technical: true }, (err, judges) ->
    return next err if err
    res.render2 'judges', judges: _.shuffle(judges), subset: 'Technical'

# new
app.get '/judges/new', (req, res, next) ->
  res.render2 'judges/new', person: new Person(role: 'nomination')

app.get '/judges/suggest', (req, res, next) ->
  res.render2 'judges/suggest'

# create
app.post '/judges', (req, res) ->
  unless req.user?.admin
    # sanitize the body
    delete req.body[attr] for attr in ['admin', 'technical', 'hiring']
    req.body.role = 'nomination'

  judge = new Person req.body
  judge.save (err) ->
    if err
      res.render2 'judges/new', person: judge
    else
      req.flash 'info', """
        Thanks for nominating #{judge.name} as a judge.
        We will review and process him/her shortly."""
      res.redirect "/people/#{judge}"

# edit (just redirects to person/edit with twitter login)
app.get '/judges/:judgeId/edit', (req, res, next) ->
  editPersonPath = "/people/#{req.param('judgeId')}/edit"
  if req.loggedIn
    res.redirect editPersonPath
  else
    res.redirect "/login/twitter?returnTo=#{editPersonPath}"
