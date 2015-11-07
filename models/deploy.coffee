mongoose = require 'mongoose'
ObjectId = mongoose.Schema.ObjectId
request = require 'request'

DeploySchema = module.exports = new mongoose.Schema
  teamId:
    type: ObjectId
    index: true
    required: true
  os: String
  remoteAddress: String
  platform: String
DeploySchema.plugin require('../lib/use-timestamps')

# associations
DeploySchema.method 'team', (callback) ->
  Team = mongoose.model 'Team'
  Team.findById @teamId, callback

# # validations
# DeploySchema.path('remoteAddress').validate (v, next) ->
#   if inNetwork v, '127.0.0.1/24'
#     return next(true)
#
#   @team (err, team) ->
#     next(false) if err
#     next(team.ip is v)
# , 'not recognized'
#
# DeploySchema.path('remoteAddress').validate (v, next) ->
#   if inNetwork v, '127.0.0.1/24'
#     v = "#{v}:8000"
#   request.get "http://#{v}", (err, response, body) ->
#     next(response?.statusCode is 200)
# , 'not responding to web requests correctly'

DeploySchema.method 'urlForTeam', (team) ->
  "http://#{team.slug}.2015.nodeknockout.com"

# callbacks
DeploySchema.post 'save', ->
  @team (err, team) =>
    throw err if err
    team.lastDeploy = @toObject()
    team.entry.url = @urlForTeam team
    team.save (err) ->
      throw err if err
      team.prettifyURL()

Deploy = mongoose.model 'Deploy', DeploySchema

toBytes = (ip) ->
  [ a, b, c, d ] = ip.split '.'
  (a << 24 | b << 16 | c << 8 | d)

inNetwork = (ip, networks) ->
  for network in networks.split(/\s+/)
    [ network, netmask ] = network.split '/'
    netmask = 0x100000000 - (1 << 32 - netmask)
    return true if (toBytes(ip) & netmask) == (toBytes(network) & netmask)
  false
