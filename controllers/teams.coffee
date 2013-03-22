_ = require 'underscore'
app = require '../config/app'
m = require './middleware'
[Person, Team, Vote] = (app.db.model s for s in ['Person', 'Team', 'Vote'])

# index
app.get /^\/teams(\/pending)?\/?$/, (req, res, next) ->
  page = (req.param('page') or 1) - 1
  query = {}
  query.peopleIds = { $size: 0 } if req.params[0]
  query.search = new RegExp(req.param('q'), 'i') if req.param('q')
  options = { sort: [['updatedAt', -1]], limit: 50, skip: 50 * page }
  # TODO move this join-thing into the Team model (see Vote <-> Person)
  Team.find query, {}, options, (err, teams) ->
    return next err if err
    ids = _.reduce teams, ((r, t) -> r.concat(t.peopleIds)), []
    only =
      email: 1
      slug: 1
      name: 1
      location: 1
      imageURL: 1
      'github.gravatarId': 1
      'github.login': 1
      'twit.screenName': 1
    Person.find _id: { $in: ids }, only, (err, people) ->
      return next err if err
      people = _.reduce people, ((h, p) -> h[p.id] = p; h), {}
      Team.count query, (err, count) ->
        return next err if err
        teams.count = count
        layout = req.header('x-pjax')? || !req.xhr
        res.render2 'teams', teams: teams, people: people, layout: layout


# entries index
app.get /^\/(entries)?\/?$/, (req, res, next) ->
  voting = app.enabled('voting')

  # only show entries that are deployed and marked votable
  query = { 'entry.votable': true, lastDeploy: {$ne: null} }
  query.search = new RegExp(req.param('q'), 'i') if req.param('q')

  # determine what category to show
  sort = if _.include(Vote.dimensions.concat('popularity', 'team', 'solo'), req.param('sort'))
      req.param('sort')
    else
      null

  # during voting, only contestants can sort by category
  if voting and not req.user?.contestant and not req.user?.admin and not req.user?.judge
    sort = null

  # handle overall vs solo (TODO should be team, not overall)
  score = sort
  if sort is 'solo'
    query['scores.team_size'] = 1
    score = 'overall'
  else if sort is 'team'
    query['scores.team_size'] = { $gt: 1 }
    score = 'overall'

  # pagination
  page = (req.param('page') or 1) - 1
  options = { limit: 30, skip: 30 * page }

  # if there is sorting, then use it, otherwise sort by something arbitrary
  if score
    options.sort = [["scores.#{score}", -1]]
  else if req.user?.contestant
    options.sort = [["scores.random", 1]]
  else
    options.sort = [["judgeVisitedAt", -1]]

  renderEntries = ->
    Team.find query, {}, options, (err, teams) ->
      return next err if err
      Team.count query, (err, count) ->
        return next err if err
        teams.count = count
        layout = req.header('x-pjax')? || !req.xhr
        res.render2 'teams/entries', teams: teams, sort: sort, score: score, layout: layout

  # while voting is going on, only allow sorting for teams that the user is on
  # or has voted on
  if voting and score and not req.user?.admin and not req.user?.judge
    req.user.votedOnTeamIds (err, teamIds) ->
      return next(err) if err
      req.user.team (err, team) ->
        return next(err) if err
        query._id = ($in: teamIds.concat(team.id))
        renderEntries()
  else # voting is over, allow everything to be seen
    renderEntries()

# new
app.get '/teams/new', (req, res, next) ->
  Team.canRegister (err, yeah) ->
    return next err if err
    if yeah
      team = new Team
      team.emails = [ req.user.github.email ] if req.user
      res.render2 'teams/new', team: team
    else
      res.render2 'teams/max'

# create
app.post '/teams', (req, res, next) ->
  team = new Team req.body
  team.save (err) ->
    return next err if err and err.name != 'ValidationError'
    if team.errors
      res.render2 'teams/new', team: team
    else
      req.session.team = team.code
      res.redirect "/teams/#{team}"

# my team
app.get '/teams/mine(\/edit)?', [m.ensureAuth, m.loadPerson, m.loadPersonTeam], (req, res, next) ->
  return next 404 unless req.team
  res.redirect "/teams/#{req.team}#{req.params[0] || ''}"

# show (join)
app.get '/teams/:id', [m.loadTeam, m.loadTeamPeople, m.loadTeamVotes, m.loadMyVote, m.loadCanSeeVotes], (req, res) ->
  req.session.invite = req.param('invite') if req.param('invite')

  vote = req.vote or new Vote
  vote.team = req.team
  vote.person = req.user
  res.render2 'teams/show',
    team: req.team
    people: req.people
    publicVotes: req.publicVotes
    votes: req.votes
    vote: vote
    canSeeVotes: req.canSeeVotes

# resend invitation
app.all '/teams/:id/invites/:inviteId', [m.loadTeam, m.ensureAccess], (req, res) ->
  req.team.invites.id(req.param('inviteId')).send(true)
  res.redirect "/teams/#{req.team}"

# edit
app.get '/teams/:id/edit', [m.loadTeam, m.ensureAccess, m.loadTeamPeople], (req, res) ->
  res.render2 'teams/edit', team: req.team, people: req.people

# edit entry
app.get '/teams/:id/entry/edit', [m.loadTeam, m.ensureAccess], (req, res) ->
  res.render2 'entries/edit', team: req.team, entry: req.team.entry

# update
app.put '/teams/:id', [m.loadTeam, m.ensureAccess], (req, res, next) ->
  unless req.user?.admin
    delete req.body[attr] for attr in ['slug', 'code', 'search', 'scores']
    delete req.body.entry.url if req.body.entry
  _.extend req.team, req.body
  req.team.save (err) ->
    return next err if err and err.name != 'ValidationError'
    if req.team.errors
      req.team.people (err, people) ->
        return next err if err
        res.render2 'teams/edit', team: req.team, people: people
    else
      res.redirect "/teams/#{req.team}"
  null

# delete
app.delete '/teams/:id', [m.loadTeam, m.ensureAccess], (req, res, next) ->
  req.team.remove (err) ->
    return next err if err
    res.redirect '/teams'
