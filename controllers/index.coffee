util = require 'util'
_ = require 'underscore'
app = require '../config/app'
Team = app.db.model 'Team'
Person = app.db.model 'Person'
Service = app.db.model 'Service'
Vote = app.db.model 'Vote'
m = require './middleware'

# middleware
loadCurrentPersonWithTeam = (req, res, next) ->
  return next() unless req.user
  req.user.team (err, team) ->
    return next err if err
    req.team = team
    next()

loadCanRegister = (req, res, next) ->
  Team.canRegister (err, canRegister, left) ->
    return next err if err
    req.canRegister = canRegister
    req.teamsLeft = left
    next()

loadRecentDeploys = (req, res, next) ->
  Team.find { 'lastDeploy.createdAt': { '$exists': 1 }, 'entry.url' : /\w/ }, {},
    { limit: 5, sort: { 'lastDeploy.createdAt': -1 }}, (err, teams) ->
      return next(err) if err
      req.recentDeploys = teams
      next()

# load the teams that were most recently visited for judging (or, if nothing
# has been judged, by popularity)
loadInterestingTeams = (req, res, next) ->
  Team.find { 'entry.votable': true }, {},
    { limit: 12, sort: { 'judgeVisitedAt': -1, 'scores.popularity': -1 }}, (err, teams) ->
      return next(err) if err
      req.interestingTeams = teams
      next()

loadFeaturedJudges = (req, res, next) ->
  Person.find { role: 'judge', featured: true }, (err, judges) ->
    return next err if err
    req.featuredJudges = _.chain(judges).shuffle().first(18).groupBy((a,b) -> Math.floor(b/6)).value()
    next()

# app.get '/', (req, res, next) ->
#   res.render2 'index/index'
app.get '/', [loadCanRegister, loadCurrentPersonWithTeam, loadRecentDeploys, loadInterestingTeams, loadFeaturedJudges], (req, res, next) ->

  if app.enabled('coding')
    template = 'index/coding'
  else if app.enabled('post-coding')
    template = 'index/postcoding'
  else if app.enabled('voting') or app.enabled('post-voting')
    template = 'index/voting'
  else if app.enabled('winners')
    template = 'index/winners'
  else
    template = 'index/index'

  res.render2 template,
    team: req.team
    stats: app.stats
    recentDeploys: req.recentDeploys
    interestingTeams: req.interestingTeams
    featuredJudges: req.featuredJudges

app.get '/blog', (req, res) -> res.redirect("http://blog.nodeknockout.com/")

# [ 'rules', 'sponsors'].forEach (p) ->
#   if app.enabled('pre-registration')
#     app.get '/' + p, (req, res) -> res.redirect("http://blog.nodeknockout.com/#{p}")
#   else
#     app.get '/' + p, (req, res) -> res.render2 "index/#{p}"

[ 'rules', 'sponsors', 'locations', 'prizes', 'scoring', 'jobs', 'how-to-win', 'tell-me-a-story' ].forEach (p) ->
  app.get '/' + p, (req, res) -> res.render2 "index/#{p}"

app.get '/sponsors/options', (req, res) -> res.render2 "index/sponsor-options"

app.get '/support', (req, res) ->
  if req.user
    name = req.user.name
  res.render2 'index/support', name: name

app.get '/about', (req, res) ->
  Team.count {}, (err, teams) ->
    return next err if err
    Person.count { role: 'contestant' }, (err, people) ->
      return next err if err
      Team.count 'entry.votable': true, lastDeploy: {$ne: null}, (err, entries) ->
        return next err if err
        Vote.count {}, (err, votes) ->
          return next err if err
          res.render2 'index/about',
            teams: teams - 1   # compensate for team fortnight
            people: people - 4
            entries: entries
            votes: votes

app.get '/judging', (req, res) ->
  # res.render2 'index/judging'
  res.redirect '/judges/new'

app.get '/now', (req, res) ->
  res.send Date.now().toString()
  #res.send Date.UTC(2012, 10, 9, 23, 59, 55).toString()     # 0 days left
  #res.send Date.UTC(2012, 10, 10, 0, 59, 55).toString()     # go!
  #res.send Date.UTC(2012, 10, 8, 23, 59, 55).toString() # 1 -> 0 days left

app.get '/reload', (req, res, next) ->
  # only allow this to be called from localhost
  return next(401) unless req.connection.remoteAddress is '127.0.0.1'
  app.events.emit 'reload'
  res.redirect '/'

app.get '/scores', (req, res, next) ->
  return next(401) unless app.enabled('winners') or req.user?.admin
  Team.sortedByScore (error, teams) ->
    return next error if error
    res.render2 'index/scores', teams: teams

app.get '/scores/update', (req, res, next) ->
  return next(401) unless req.user?.admin or (req.connection.remoteAddress is '127.0.0.1')
  Team.updateAllSavedScores (err) ->
    next err if err
    res.redirect '/scores'

app.get '/resources', (req, res, next) ->
  Service.asObject (error, services) ->
    next error if error
    res.render2 'index/resources', services: services
