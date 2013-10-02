_ = require 'underscore'
app = require '../config/app'
Person = app.db.model 'Person'

# index
app.get '/judges', (req, res, next) ->
  if app.enabled('pre-registration')
    res.redirect("/judges/suggest")
  else
    Person.find { role: 'judge' }, (err, judges) ->
      return next err if err
      res.render2 'judges', judges: _.shuffle(judges)

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
  unless req.user.admin
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
