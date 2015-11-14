_ = require 'underscore'
mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId
Person = mongoose.model 'Person'
util = require 'util'
env = require '../config/env'
postageapp = require('postageapp')(env.secrets.postageapp)

Dimension =
  type: Number
  validate: [ (v) ->
    v == null || 0 < v < 6
  , 'out of bounds' ]

ReplySchema = new mongoose.Schema
  personId:
    type: ObjectId
    required: true
  person: {}
  message: String

# instance methods
ReplySchema.method 'notifyPeople', (vote) ->
  peopleIds = vote.team.peopleIds.concat vote.personId
  Person.find { _id: ($in: peopleIds) }, (err, people) =>
    throw err if err
    isCommenter = (p) => @personId.equals p.id
    commenter = _.detect people, isCommenter
    others = _.reject people, isCommenter

    for person in others
      template = "replied_#{if vote.personId.equals(person.id) then 'judge' else 'team'}"
      util.log "Sending '#{template}' to '#{person.email}'".yellow
      if env.skip_emails
        util.log "skipping email (in dev)..."
      else
        postageapp.sendMessage
          recipients: person.email
          template: template
          variables:
            vote_id: vote.id
            person_id: commenter.id
            person_name: commenter.name
            message: @message
            team_id: vote.team.slug
            entry_name: vote.team.entry.name
          , (err, data) ->
            return console.error(err) if err?
            console.log(data)
VoteSchema = module.exports = new mongoose.Schema
  personId:
    type: ObjectId
    required: true
  teamId:
    type: ObjectId
    required: true
  type:
    type: String
    required: true
    enum: Person.ROLES
  comment: String
  utility: Dimension
  design: Dimension
  innovation: Dimension
  completeness: Dimension
  audit:
    remoteAddress: String
    remotePort: Number
    userAgent: String
    referrer: String
    accept: String
    requestAt: Number
    hoverAt: Number
  replies: [ReplySchema]
VoteSchema.plugin require('../lib/use-timestamps')

# one vote per person-team-type
VoteSchema.index { personId: 1, teamId: 1, type: 1 }, { unique: true }
VoteSchema.index { personId: 1, updatedAt: -1 }
VoteSchema.index { teamId: 1, updatedAt: -1 }

# class methods
VoteSchema.static 'dimensions',
  [ 'utility', 'design', 'innovation', 'completeness' ]
VoteSchema.static 'label', (dimension) ->
  switch dimension
    when 'utility'      then 'Utility/Fun'
    when 'design'       then 'Design'
    when 'innovation'   then 'Innovation'
    when 'completeness' then 'Completeness'
VoteSchema.static 'Reply', -> Reply

# instance methods
VoteSchema.method 'replyable', (person) ->
  @personId.equals(person.id) or
    @team.includes(person)

VoteSchema.method 'notifyTeam', ->
  @team.people (err, people) =>
    throw err if err

    @person.team (err, voterTeam) =>
      throw err if err

      for person in people
        util.log "Sending 'voted_on_by_#{@type}' to '#{person.email}'".yellow

        if env.skip_emails
          util.log "skipping email (in dev)..."
        else
          postageapp.sendMessage
            recipients: person.email
            template: "voted_on_by_#{@type}"
            variables:
              vote_id: @id
              person_id: @person.id
              person_name: @person.name
              utility_score: @utility
              design_score: @design
              innovation_score: @innovation
              completeness_score: @completeness
              comment: @comment
              team_id: @team.slug
              entry_name: @team.entry.name
              person_team_id: voterTeam?.slug
              person_entry_name: voterTeam?.entry?.name
            , (err, data) ->
              return console.error(err) if err?
              console.log(data)

# associations
VoteSchema.static 'people', (votes, next) ->
  peopleIds = _.pluck votes, 'personId'
  return next() if peopleIds.length == 0
  # TODO only need certain fields probably; make `only` an argument
  Person.find _id: { '$in': peopleIds }, (err, people) ->
    return next err if err
    people = _.reduce people, ((h, p) -> h[p.id] = p; h), {}
    _.each votes, (v) -> v.person = people[v.personId]
    next()
VoteSchema.static 'teams', (votes, next) ->
  teamIds = _.pluck votes, 'teamId'
  return next() if teamIds.length == 0
  # TODO only need certain fields probably; make `only` an argument
  Team = mongoose.model 'Team'
  Team.find _id: { '$in': teamIds }, (err, teams) ->
    return next err if err
    teams = _.reduce teams, ((h, t) -> h[t.id] = t; h), {}
    _.each votes, (v) -> v.team = teams[v.teamId]
    next()

Reply = mongoose.model 'Reply', ReplySchema
Vote = mongoose.model 'Vote', VoteSchema
