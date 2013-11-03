# setup teams, taking care not to run things for teams that are already setup

async = require('async')
mongoose = require('../../models')(require('../../config/env').mongo_url)
spawn = require('child_process').spawn
path = require('path')

rootDir = path.join(__dirname, '..', '..')
Team = mongoose.model 'Team'
slug = ''
team = null

hasTeam = -> team

processTeam = (next) ->
  async.series [loadTeam, setupTeam], next

loadTeam = (next) ->
  selectTeam (err, res) ->
    return next(err) if err
    unless res?._id
      team = null
      return next(res)
    Team.findById res._id, (err, _team) ->
      team = _team
      next(err)

setupTeam = (next) ->
  return next() unless team
  console.log team.slug, 'setting up team...'
  team.setup.log ?= ''

  setupData = (data) ->
    process.stdout.write data
    team.setup.log += data.toString()
    team.save -> # nothing

  setupError = (err) ->
    team.setup.status = 'error'
    team.setup.log += "\n\nError: #{err}"
    team.save next

  setupCompleted = ->
    team.setup.status = 'completed'
    team.save next

  coffee = path.join(rootDir, 'node_modules', '.bin', 'coffee')
  setupScript = path.join(rootDir, 'scripts', 'setup', 'setup-team.coffee')
  setup = spawn coffee, [setupScript, team.slug], cwd: rootDir
  setup.stdout.on 'data', setupData
  setup.stderr.on 'data', setupData
  setup.on 'error', (err) -> setupError(err)
  setup.on 'exit', (err) ->
    return setupError(err) if err
    setupCompleted()

# atomically select a team that is not being setup
selectTeam = (next) ->
  query = { 'setup.status': 'ready' }
  sort = []
  update = { $set: { 'setup.status': 'processing' }}
  options = {}

  Team.collection.findAndModify(query, sort, update, options, next)

last = (err) ->
  if err
    console.log(err)
    process.exit(1)
  else
    mongoose.connection.close()

async.doWhilst processTeam, hasTeam, last
