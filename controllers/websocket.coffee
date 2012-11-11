util = require 'util'
app = require '../config/app'

app.ws?.sockets.on 'connection', (client) ->
  client.on 'message', (data) ->
    return if Date.now() - client.lastMessageAt < 100
    client.lastMessageAt = Date.now()
    data.id = client.id
    client.json.broadcast.send data
  client.on 'disconnect', ->
    client.json.broadcast.send id: client.id, disconnect: true

app.events.on 'reload', ->
  app.ws?.sockets.emit 'reload'

app.events.on 'updateTeamStats', (team) ->
  app.ws?.sockets.json.emit 'updateTeamStats',
    teamId: team.id
    stats: team.stats

app.events.on 'updateStats', (stats) ->
  app.ws?.sockets.json.emit 'updateStats', stats

app.events.on 'deploy', (deploy, team) ->
  app.ws?.sockets.json.emit 'deploy', team.entryInfoJSON()

app.events.on 'judgeVisit', (team) ->
  app.ws?.sockets.json.emit 'judgeVisit', team.entryInfoJSON()
