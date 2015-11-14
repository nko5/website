mongoose = require 'mongoose'
crypto = require 'crypto'
util = require 'util'
env = require '../config/env'
postageapp = require('postageapp')(env.secrets.postageapp)
qs = require 'querystring'

InviteSchema = module.exports = new mongoose.Schema
  email: String
  sent:
    type: Boolean
    default: no
  code:
    type: String
    default: -> crypto.randomBytes(12).toString('base64').replace(/\+/g, '-').replace(/\//g, '_')

InviteSchema.method 'send', (force) ->
  if not @sent or force
    util.log "Sending 'teams_new' to '#{@email}'".yellow
    team = @parentArray()._parent

    if env.skip_emails
      util.log "skipping email (in dev)..."
    else
      postageapp.sendMessage
        recipients: @email,
        template: 'teams_new'
        variables:
          team_id: team._id
          team_name: team.name
          invite_code: qs.escape @code
        , (err, data) ->
          return console.error(err) if err?
          console.log(data)
    @sent = yes

mongoose.model 'Invite', InviteSchema
