crypto = require 'crypto'
_ = require 'underscore'
mongoose = require 'mongoose'
auth = require 'mongoose-auth'
env = require '../config/env'
ROLES = [ 'nomination', 'contestant', 'judge', 'voter' ]
request = require('request')
util = require('util')

# auth decoration
PersonSchema = module.exports = new mongoose.Schema
  name: String
  email: String
  imageURL: String
  location: String
  company: String
  hiring: String
  twitterScreenName: String
  bio: String
  admin: Boolean
  role: { type: String, enum: ROLES }
  technical: Boolean
  slug:
    type: String
    index: true
  skippedTeamIds: [ mongoose.Schema.ObjectId ]
PersonSchema.plugin require('../lib/use-timestamps')
PersonSchema.plugin auth,
  everymodule:
    everyauth:
      moduleTimeout: 10000
      findUserById: (userId, fn) -> Person.findById(userId, fn)
      handleLogout: (req, res) ->
        req.logout()
        res.redirect(req.param('returnTo') || req.header('referrer') || '/')
  github:
    everyauth:
      scope: 'user'
      redirectPath: '/login/done'
      myHostname: env.hostname
      appId: env.github_app_id
      appSecret: env.secrets.github
      findOrCreateUser: (sess, accessTok, accessTokExtra, ghUser) ->
        promise = @Promise()
        Person.findOne 'github.id': ghUser.id,
          (err, foundUser) ->
            if foundUser
              foundUser.updateWithGithub ghUser, accessTok, (err, updatedUser) ->
                return promise.fail err if err
                promise.fulfill updatedUser
            else if sess.invite
              Team = mongoose.model 'Team'
              Team.findOne 'invites.code': sess.invite, (err, team) ->
                return promise.fail err if err
                return promise.fulfill(id: null) unless team
                Person.createWithGithub ghUser, accessTok, (err, createdUser) ->
                  return promise.fail err if err
                  promise.fulfill createdUser
            else
              Person.createWithGithub ghUser, accessTok, (err, createdUser) ->
                return promise.fail err if err
                createdUser.updateWithGithub ghUser, accessTok, (err, updatedUser) ->
                  return promise.fail err if err
                  promise.fulfill updatedUser
        promise
  twitter:
    everyauth:
      redirectPath: '/login/done'
      myHostname: env.hostname
      consumerKey: env.twitter_app_id
      consumerSecret: env.secrets.twitter
      findOrCreateUser: (session, accessTok, accessTokExtra, twit) ->
        promise = @Promise()
        screenName = new RegExp("^#{RegExp.escape twit.screen_name}$", 'i')
        Person.findOne
          $or: [ { 'twit.id': twit.id }, { twitterScreenName: screenName } ]
          role: { $in: [ 'judge', 'nomination' ] }
          (err, person) ->
            return promise.fail err if err
            if not person
              session.twitterScreenName = twit.screen_name
              util.error "ERROR: Twitter login failed. No judge login found for @#{twit.screen_name}.".red
              return promise.fulfill(id: null)
            person.updateWithTwitter twit, accessTok, accessTokExtra,
              (err, updatedUser) ->
                return promise.fail err if err
                promise.fulfill updatedUser
        promise
  facebook:
    everyauth:
      redirectPath: '/login/done'
      myHostname: env.hostname
      appId: env.facebook_app_id
      appSecret: env.secrets.facebook
      findOrCreateUser: (session, accessTok, accessTokExtra, face) ->
        promise = @Promise()
        Person.findOne 'fb.id': face.id, role: 'voter',
          (err, person) ->
            return promise.fail err if err
            person ||= new Person role: 'voter'
            person.updateWithFB face, accessTok, accessTokExtra.expires,
              (err, updatedUser) ->
                return promise.fail err if err
                promise.fulfill updatedUser
        promise

# validations
twitterValidator = (twitterHandle, callback) ->
  return callback(true) unless @nomination
  request
    url: 'http://api.twitter.com/1/users/show.json'
    qs: { screen_name: twitterHandle }
    callback: (error, res) ->
      callback(not error and res.statusCode is 200)
PersonSchema.path('twitterScreenName').validate twitterValidator,
  'is required to exist and be valid for judges'

# instance methods
PersonSchema.method 'toString', -> @id
ROLES.forEach (t) ->
  PersonSchema.virtual(t).get -> @role == t
PersonSchema.virtual('login').get ->
  @github?.login or @twit?.screenName or @name.split(' ')[0]
PersonSchema.virtual('githubLogin').get -> @github?.login
# twitterScreenName isn't here because you can edit it

md5 = (str) ->
  hash = crypto.createHash 'md5'
  hash.update str
  hash.digest 'hex'
gravatarURL = (md5, size) ->
  "http://gravatar.com/avatar/#{md5}?s=#{size}&d=retro"
PersonSchema.method 'avatarURL', (size = 30) ->
  if @github?.gravatarId
    id = @github.gravatarId # HACK getter bugs
    gravatarURL id, size
  else if @imageURL
    @imageURL
  else if @email
    gravatarURL md5(@email.trim().toLowerCase()), size
  else
    '/images/gravatar_fallback.png'

PersonSchema.method 'canSeeVotes', (votes, callback) ->
  # judges can see all votes
  return callback(null, true) if @judge

  # if you've left any of the votes in the list, then you can see them all
  #
  # this works on the team page (since you can see all the votes for any of
  # the teams that you've voted for) and on your own profile page (since all
  # the votes are ones that you've left)
  for vote in votes
    return callback(null, true) if vote.personId.equals(@_id)

  # else, we need to check if your team has any votes in the list
  #
  # this works on the person page (since you can see all the votes for any
  # judge that has voted on your team), as well as on your team page (since
  # all the votes are for your team)
  @team (err, team) ->
    return callback(err) if err
    return callback(null, false) unless team

    for vote in votes
      return callback(null, true) if vote.teamId.equals(team._id)

    # oops, the team doesn't have any votes, return false
    return callback(null, false)

# class methods
PersonSchema.static 'findBySlug', (slug, rest...) ->
  Person.findOne { slug: slug }, rest...

# associations
PersonSchema.method 'team', (next) ->
  return next() unless @contestant
  Team = mongoose.model 'Team'
  Team.findOne peopleIds: @id, next
PersonSchema.method 'votes', (next) ->
  Vote = mongoose.model 'Vote'
  Vote.find personId: @id, {}, { sort: [['updatedAt', -1]] }, next
PersonSchema.method 'nextTeam', (next) ->
  filter =
    'entry.name': /\w/ # has name
    'entry.votable': true # votable
    'lastDeploy': ($ne: null) # deployed
    'peopleIds': ($ne: @id) # not mine
  # TBD - running

  # if you're a judge
  if @judge
    # non-technical judges don't see technical entries
    filter.technical = ($ne: true) if not @technical

    # judges focus on good stuff
    #filter['scores.overall'] = ($gt: 15)

    # judges only see entries with pitch videos
    filter['entry.videoURL'] = /./

  sort = []
  # sort by minimum vote count for your type
  sort.push ['voteCounts.' + @role, 1] if @judge or @contestant
  sort.push ['updatedAt', -1]

  Team = mongoose.model 'Team'
  @votedOnTeamIds (err, votedOn) =>
    next err if err

    # every third vote should be for something good
    if votedOn.length % 3 is 0
      sort.unshift ['scores.overall', -1]

    # not already voted on or skipped
    filter._id = $nin: votedOn.concat @skippedTeamIds
    Team.find filter, {}, { sort: sort, limit: 1 }, (err, teams) ->
      # findOne doesn't seem to work with sort
      next err if err
      next null, teams[0]

PersonSchema.method 'votedOnTeamIds', (callback) ->
  Vote = mongoose.model 'Vote'
  Vote.distinct 'teamId', personId: @id, callback

# callbacks

## remove from team
PersonSchema.pre 'remove', (next) ->
  myId = @_id
  @team (err, team) ->
    return next err if err
    if team
      if team.peopleIds.length is 1
        team.remove next
      else
        team.peopleIds = _.reject team.peopleIds, (id) -> id.equals(myId)
        team.save next
    else
      next()

# leaves saving up to the calling code: if passing in an invite, you'll
# probably want to save both the person and the team. w/o an invite, you just
# need to save the team.
PersonSchema.method 'join', (team, invite) ->
  team.peopleIds.push @id unless team.includes(this)
  if invite and old = _.detect(team.invites, (i) -> i.code == invite)
    _.extend this,
      name: @github.name
      email: old.email || @github.email
      role: 'contestant'
      company: @github.company
      location: @github.location
    team.emails = _.without team.emails, old.email
    old.remove()

PersonSchema.method 'updateWithGithub', (ghUser, token, callback) ->
  Person.createWithGithub.call
    create: (params, callback) =>
      _.extend this, params
      @slug = @github.login.toLowerCase()
      @company ||= @github.company
      @location ||= @github.location
      @role ||= 'voter'
      @save callback
    , ghUser, token, callback

PersonSchema.method 'updateWithTwitter', (twitter, token, secret, callback) ->
  Person.createWithTwitter.call
    create: (params, callback) =>
      _.extend this, params
      @twitterScreenName = @twit.screenName
      @slug = @twitterScreenName.toLowerCase()
      @name ||= @twit.name
      @location ||= @twit.location
      @bio ||= @twit.description
      @imageURL ||= @twit.profileImageUrl.replace('_normal.', '.')
      @save callback
    , twitter, token, secret, callback

PersonSchema.method 'updateWithFB', (facebook, token, expires, callback) ->
  Person.createWithFB.call
    create: (params, callback) =>
      _.extend this, params
      @slug = @_id
      @name ||= @fb.name.full
      @location ||= facebook.location?.name
      @bio ||= facebook.bio
      @email ||= @fb.email
      @imageURL ||= "http://graph.facebook.com/#{@fb.id}/picture?type=square"
      @save callback
    , facebook, token, expires, callback

Person = mongoose.model 'Person', PersonSchema
Person.ROLES = ROLES
