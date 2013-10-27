_ = require 'underscore'
mongoose = require 'mongoose'
crypto = require 'crypto'
querystring = require 'querystring'
request = require 'request'
env = require '../config/env'

InviteSchema = require './invite'
[TeamLimit, Invite, Person, Deploy, Vote, RegCode] = (mongoose.model m for m in ['TeamLimit', 'Invite', 'Person', 'Deploy', 'Vote', 'RegCode'])

TeamSchema = module.exports = new mongoose.Schema
  slug:
    type: String
    unique: true
  name:
    type: String
    required: true
    unique: true
  description: String
  github: Object
  regCode: String
  machine: {}
  ip: String
  entry:
    name: String
    url: String
    description: String
    instructions: String
    colophon: String
    votable:
      type: Boolean
      default: false
    technical: Boolean
    alert: Boolean
    videoURL: String
    pinkyurl: Boolean
  emails:
    type: [ mongoose.SchemaTypes.Email ]
    validate: [ ((v) -> v.length <= 4), 'max' ]
  invites: [ InviteSchema ]
  peopleIds:
    type: [ mongoose.Schema.ObjectId ]
    index: true
  lastDeploy: {}
  code:
    type: String
    default: -> crypto.randomBytes(12).toString('base64').replace(/\+/g, '-').replace(/\//g, '_')
  linode: {}
  search: String
  scores:
    random: Number
    team_size: Number
    contestant_utility: Number
    contestant_design: Number
    contestant_innovation: Number
    contestant_completeness: Number
    contestant_count: Number
    judge_utility: Number
    judge_design: Number
    judge_innovation: Number
    judge_completeness: Number
    judge_count: Number
    utility: Number
    design: Number
    innovation: Number
    completeness: Number
    popularity: Number
    popularity_count: Number
    overall: Number
  voteCounts:
    judge: Number
    contestant: Number
    voter: Number
  stats:
    pushes:
      type: Number
      default: 0
    commits:
      type: Number
      default: 0
    deploys:
      type: Number
      default: 0
  judgeVisitedAt: Date
TeamSchema.plugin require('../lib/use-timestamps')
TeamSchema.index updatedAt: -1
TeamSchema.index 'entry.url': 1

# class methods
TeamSchema.static 'findBySlug', (slug, rest...) ->
  Team.findOne { slug: slug }, rest...
TeamSchema.static 'canRegister', (regCode, next) ->
  if typeof(regCode) == "function"
    next = regCode 
    regCode = null

  return next null, false, 0 if mongoose.app.disabled('registration')  

  findOptions = {}
  if regCode
    findOptions.regCode = regCode
  
  Team.count findOptions, (err, count) ->
    return next err if err

    if regCode
      RegCode.findByCode regCode, (err, regCodeResult) =>
        return next err if err
        return next null, false, null unless regCodeResult

        newLimit = regCodeResult.limit - count
        next null, newLimit > 0, newLimit
     
    else
      TeamLimit.current (err, limit) ->
        return next err if err
        limit++ # +1 for fortnight labs team
        next null, count < limit, limit - count

TeamSchema.static 'uniqueName', (name, next) ->
  Team.count { name: name }, (err, count) -> next err, count is 0
TeamSchema.static 'sortedByScore', (next) ->
  spec = { 'entry.votable': true, lastDeploy: {$ne:null} }
  sort = { sort: [['scores.overall', -1]] }
  Team.find spec, {}, sort, next

TeamSchema.static 'updateAllSavedScores', (next) ->
  map = ->
    ret =
      contestant_utility: 0
      contestant_design: 0
      contestant_innovation: 0
      contestant_completeness: 0
      contestant_count: 0
      judge_utility: 0
      judge_design: 0
      judge_innovation: 0
      judge_completeness: 0
      judge_count: 0
      popularity_count: 0
    if this.type == 'contestant' or this.type == 'judge'
      ret[this.type + '_utility'] = this.utility
      ret[this.type + '_design'] = this.design
      ret[this.type + '_innovation'] = this.innovation
      ret[this.type + '_completeness'] = this.completeness
      ret[this.type + '_count'] = 1
    else if this.type == 'voter'
      ret.popularity_count = 1
    emit this.teamId, ret

  reduce = (key,vals) ->
    ret = vals.shift()
    vals.forEach (val) ->
      for field of ret
        ret[ field ] += val[ field ]
    ret

  finalize = (key,val) ->
    ret = {}
    [ 'contestant_utility', 'contestant_design', 'contestant_innovation', 'contestant_completeness' ].forEach (field) ->
      if val.contestant_count != 0
        ret[ field ] = val[ field ] / val.contestant_count
      else
        ret[ field ] = 0
    ret[ 'contestant_count' ] = val.contestant_count
    [ 'judge_utility', 'judge_design', 'judge_innovation', 'judge_completeness' ].forEach (field) ->
      if val.judge_count != 0
        ret[ field ] = val[ field ] / val.judge_count
      else
        ret[ field ] = 0
    ret[ 'judge_count' ] = val.judge_count
    ret[ 'popularity_count' ] = val.popularity_count
    ret

  mrCommand =
    mapreduce:'votes'
    map:map.toString()
    reduce:reduce.toString()
    finalize:finalize.toString()
    out:{inline:1}

  mongoose.connection.db.executeDbCommand mrCommand, (err, result) ->
    if err or not result.documents[0].ok
      console.log err
      #console.log result
      return next [err,result]

    computedScores = result.documents[0].results

    popularities = _.uniq computedScores.map((s) -> s.value.popularity_count).sort((a, b) -> a - b)
    popularityRanks = {}
    popularityCount = popularities.length
    for p, rank in popularities
      popularityRanks[p] = rank / (popularityCount - 1)
    #console.log popularityRanks

    Team.find {}, (err,teams) ->
      teams.forEach (team) ->
        id = team._id
        scores = team.scores
        computedScore = _.detect computedScores, (x) ->
          id.equals x._id
        if computedScore
          overall = 0
          for field of computedScore.value
            scores[ field ] = computedScore.value[ field ]
            if field != 'contestant_count' and field != 'judge_count' and field != 'popularity_count'
              overall += computedScore.value[ field ]

          scores.popularity = (popularityRanks[computedScore.value.popularity_count] or 0) * 8 + 2
          overall += scores.popularity

          scores.overall = overall
          scores.utility = scores.contestant_utility + scores.judge_utility
          scores.design = scores.contestant_design + scores.judge_design
          scores.innovation = scores.contestant_innovation + scores.judge_innovation
          scores.completeness = scores.contestant_completeness + scores.judge_completeness
        else
          TeamSchema.eachPath (path) ->
            if path.indexOf('scores.') == 0
              scores[ path.substring 7 ] = 0
        _.extend team.voteCounts,
          judge: scores.judge_count
          contestant: scores.contestant_count
          voter: scores.popularity_count
        scores.random = Math.random()
        scores.team_size = team.peopleIds.length
        team.save()
    next()

# instance methods
TeamSchema.method 'toString', -> @slug or @id
TeamSchema.method 'includes', (person, code) ->
  @code == code or person and _.any @peopleIds, (id) -> id.equals(person.id)
TeamSchema.method 'invited', (invite) ->
  _.detect @invites, (i) -> i.code == invite

TeamSchema.method 'prettifyURL', ->
  return unless url = @entry.url
  r = request.get url, (error, response, body) =>
    throw error if error
    @entry.url = (if typeof(r.uri) is 'string' then r.uri else r.uri.href) or @entry.url
    @save()

TeamSchema.virtual('screenshot').get ->
  return unless url = @entry.url
  if @entry.pinkyurl
    qs = querystring.stringify url: url, resize: '320x186', 'out-format': 'png'
    "http://pinkyurl.com/i?#{qs}"
  else
    qs = querystring.stringify
      url: url
      viewport: '1024x595'
      thumbnail_max_width: '320'
    md5 = crypto.createHash 'md5'
    md5.update qs.toString(), 'ascii'
    md5.update env.secrets.url2png, 'ascii'
    token = md5.digest 'hex'
    "http://alpha.url2png.com/v6/P50A14826D8629/#{token}/png/?#{qs}"

TeamSchema.method 'updateScreenshot', (callback) ->
  return unless @entry.url
  setTimeout =>
    request.get "#{@screenshot}&expire=1", (error, response, body) ->
      throw error if error
      # no callback
  , 8000

TeamSchema.method 'incrementStats', (stats, callback) ->
  $inc = {}
  for k, v of stats
    $inc["stats.#{k}"] = v
  @update $inc: $inc, (err, res) =>
    return callback(err) if err
    # return the reloaded the team (after the increment has been applied)
    Team.findOne _id: @id, callback

TeamSchema.method 'twitterScreenNames', (callback) ->
  @people (err, people) ->
    return callback(err) if err
    twitterScreenNames = for p in people when p.twitterScreenName
      p.twitterScreenName
    callback null, twitterScreenNames

TeamSchema.method 'entryInfoJSON', ->
  id: @id
  slug: @slug
  screenshot: @screenshot
  name: @name
  entry:
    url: @entry.url
    name: @entry.name

# associations
TeamSchema.method 'people', (next) ->
  Person.find _id: { '$in': @peopleIds }, next
TeamSchema.method 'deploys', (next) ->
  Deploy.find teamId: @id, next
TeamSchema.method 'votes', (next) ->
  Vote.find teamId: @id, {}, { sort: [['updatedAt', -1]] }, next

# validations

## min people
TeamSchema.pre 'save', (next) ->
  if @peopleIds.length + @emails.length == 0
    error = new mongoose.Document.ValidationError this
    error.errors.emails = 'You have to insert at least one email contact for your team'
    next error
  else
    next()

## max teams
TeamSchema.pre 'save', (next) ->
  return next() unless @isNew

  Team.canRegister @regCode, (err, yeah) =>
    return next err if err
    if yeah
      next()
    else
      error = new mongoose.Document.ValidationError this
      error.errors._base = 'We have reached the maximum amount of teams at the moment'
      next error

## unique name
TeamSchema.pre 'save', (next) ->
  return next() unless @isNew
  Team.uniqueName @name, (err, yeah) =>
    return next err if err
    if yeah
      next()
    else
      error = new mongoose.Document.ValidationError this
      error.errors.name = 'This team name is already in use'
      next error

## unique slug

uniquifySlug = (base, attempt, okId, next) ->
  unique = if attempt is 0 then base else "#{base}-#{attempt}"
  Team.count { slug: unique, _id: { $ne: okId } }, (err, count) ->
    return next err if err
    if count is 0
      next null, unique
    else
      uniquifySlug base, attempt + 1, okId, next

TeamSchema.virtual('slugBase').get ->
  @name
    .toLowerCase()
    .replace(/['"]+/g, '')
    .replace(/[^-a-zA-Z0-9]+/g, '-')
    .replace(/^-/, '')
    .substring(0, 20)  # arbitrarily below some limits (email, dns, etc.)
    .replace(/-$/, '')
TeamSchema.pre 'save', (next) ->
  return next() if @slug?
  uniquifySlug @slugBase, 0, @_id, (err, uniqueSlug) =>
    return next err if err
    @slug = uniqueSlug
    next()


# callbacks

## create invites
TeamSchema.pre 'save', (next) ->
  for email in @emails
    unless _.detect(@invites, (i) -> i.email == email)
      @invites.push new Invite(email: email)
  _.invoke @invites, 'send'
  next()
TeamSchema.post 'save', ->
  for invite in @invites
    invite.remove() unless !invite or _.include(@emails, invite.email)
  @save() if @isModified 'invites'

## remove team members
TeamSchema.path('peopleIds').set (v) ->
  v.init = @peopleIds
  v
TeamSchema.pre 'save', (next) ->
  return next() unless @peopleIds.init
  toString = (i) -> i.toString()
  o = @peopleIds.init.map toString
  n = @peopleIds.map toString
  Person.remove role: 'contestant', _id: { $in: _.difference(o, n) }, next
TeamSchema.pre 'remove', (next) ->
  Person.remove role: 'contestant', _id: { $in: @peopleIds }, next

## search index
TeamSchema.pre 'save', (next) ->
  only = name: 1, location: 1, 'github.login': 1, 'twit.screenName': 1, entry: 1
  Person.find _id: { '$in': @peopleIds }, only, (err, people) =>
    return next err if err
    @search =
      """
      #{@name}
      #{@description}
      #{_.pluck(people, 'login').join(';')}
      #{_.pluck(people, 'location').join(';')}
      #{@entry?.name || ''}
      #{@entry?.description || ''}
      """
    next()

Team = mongoose.model 'Team', TeamSchema
