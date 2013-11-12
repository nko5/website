app = require '../config/app'
{ ensureAuth, loadPerson, loadPersonTeam } = require './middleware'
Team = app.db.model 'Team'
url = require 'url'

setReturnTo = (req, res, next) ->
  unless req.returnTo = req.param('returnTo')
    r = url.parse(req.header('referrer') or '')
    p = r.pathname
    if r.host is req.header('host') and p and p isnt '/login' and p isnt '/'
      referrer = "#{p}#{r.search or ''}#{r.hash or ''}"
    req.returnTo = referrer
  next()

app.get '/login', [setReturnTo], (req, res) ->
  if req.loggedIn
    res.redirect req.returnTo
  else
    req.session.returnTo = req.returnTo
    res.render2 'login'

app.get '/login/done', [ensureAuth, loadPerson, loadPersonTeam], (req, res, next) ->
  if !req.person
    return next 401
  else if (!req.user.role || req.user.voter || req.user.contestant) and (invite = req.session.invite)
    Team.findOne 'invites.code': invite, (err, team) ->
      return next err if err
      if team
        req.person.join team, invite
        req.person.save (err) ->
          return next err if err
          team.save (err) ->
            return next err if err
            delete req.session.invite
            res.redirect "/teams/#{team}"
      else
        delete req.session.invite
        res.redirect '/teams/new'
  else if app.enabled('registration') and req.user.contestant and (code = req.session.team)
    Team.findOne code: code, (err, team) ->
      return next err if err
      if team
        res.redirect '/teams/' + team.id
      else
        delete req.session.team
        res.redirect '/teams/new'
  else if returnTo = req.session.returnTo
    delete req.session.returnTo
    res.redirect returnTo
  else if req.user.judge or req.user.nomination
    res.redirect "/people/#{req.person}"
  else if req.team
    res.redirect "/teams/#{req.team}"
  else
    res.redirect '/'

# order matters
app.get '/login/:service?', [setReturnTo], (req, res, next) ->
  req.logout()
  req.session.returnTo or= req.returnTo
  res.redirect "/auth/#{req.param('service') or 'github'}"
