qs = require 'querystring'
app = require '../config/app'
[Person, Team, Vote] = (app.db.model m for m in ['Person', 'Team', 'Vote'])

ensureAuth = (req, res, next) ->
  return res.redirect "/login?returnTo=#{encodeURIComponent(req.url)}" unless req.loggedIn
  next()

module.exports =
  ensureAuth: ensureAuth

  ensureAccess: (req, res, next) ->
    return next() if req.team? and req.team.includes(null, req.session.team)
    ensureAuth req, res, ->
      unless req.user.admin
        return next 401 if req.person? and req.person.id isnt req.user.id
        return next 401 if req.team? and not req.team.includes(req.user, req.session.team)
        return next 401 if req.vote? and req.vote.personId.toString() isnt req.user.id
      next()

  ensureAdmin: (req, res, next) ->
    ensureAuth req, res, ->
      return next 401 unless req.user.admin
      next()

  loadPerson: (req, res, next) ->
    if id = req.params.personId or req.params.id
      findBy = if /^[0-9a-fA-F]{24}$/.test(id) then 'findById' else 'findBySlug'
      Person[findBy] id, (err, person) ->
        return next err if err
        return next 404 unless person
        req.person = person
        next()
    else
      req.person = req.user
      next()

  loadPersonTeam: (req, res, next) ->
    return next() unless req.person
    req.person.team (err, team) ->
      return next err if err
      req.team = team
      next()

  # loads person team for the nav (TODO DRY with above)
  loadMyTeam: (req, res, next) ->
    return next() unless req.user
    req.user.team (err, team) ->
      team = null if err
      req.myTeam = team
      next()

  loadPersonVotes: (req, res, next) ->
    return next() unless req.person
    req.person.votes (err, votes) ->
      return next err if err
      req.votes = votes
      Vote.teams votes, next

  loadTeam: (req, res, next) ->
    if id = req.params.teamId or req.params.id
      findBy = if /^[0-9a-fA-F]{24}$/.test(id) then 'findById' else 'findBySlug'
      Team[findBy] id, (err, team) ->
        return next err if err && err.message != 'Invalid ObjectId'
        return next 404 unless team
        req.team = team
        next()
    else if code = req.params.code
      code = qs.unescape(code)
      Team.findOne code: code, (err, team) ->
        return next err if err
        return next 404 unless team
        req.team = team
        next()
    else
      next()

  loadTeamPeople: (req, res, next) ->
    req.team.people (err, people) ->
      return next err if err
      req.people = people
      next()

  loadTeamVotes: (req, res, next) ->
    query = teamId: req.team.id
    # exclude my vote from the vote list on the team page
    if req.user && !req.user.voter
      query.personId = $ne: req.user.id
    else if app.enabled('voting')
      req.publicVotes = []
      req.votes = []
      return next()
    Vote.find query, {}, { sort: [['updatedAt', -1]] }, (err, votes) ->
      return next err if err
      publicVotes = []
      judgeVotes = []
      votes.forEach (v) ->
        v.team = req.team
        if v.type == 'voter'
          publicVotes.push v
        else
          judgeVotes.push v
      req.publicVotes = publicVotes
      req.votes = judgeVotes
      Vote.people votes, next

  loadMyVote: (req, res, next) ->
    return next() unless req.user?
    Vote.findOne { teamId: req.team.id, personId: req.user.id }, (err, vote) ->
      return next err if err
      req.vote = vote
      next()

  # sets `req.canSeeVotes` based on if `req.user` can see the votes in `req.votes`
  loadCanSeeVotes: (req, res, next) ->
    # once voting is over, everybody can see votes
    if not app.enabled('voting')
      req.canSeeVotes = true
      return next()
    # else, voting is going on

    # if you are not logged in, you can't see votes
    if not req.user
      req.canSeeVotes = false
      return next()
    # else, you are logged in

    # get a consolidated list of votes, handling the team page, where
    # req.votes exclude's the current user's vote on the team
    votes = if req.vote and not req.vote.isNew
        req.votes.concat(req.vote)
      else
        req.votes

    # delegate to the logged in user's `canSeeVotes` method
    req.user.canSeeVotes votes, (err, canSeeVotes) ->
      return next err if err
      req.canSeeVotes = canSeeVotes
      next()

  loadVote: (req, res, next) ->
    if id = req.params.voteId or req.params.id
      Vote.findById id, (err, vote) ->
        return next err if err
        return next 404 unless vote
        req.vote = vote
        next()
    else
      next()
