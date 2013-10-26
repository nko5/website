# update the teams' slugs one last time to something best. a table at the end
# is printed out to go over by eye to fix up any emoji, unicode, or extra long
# ones.

require 'colors'
mongoose = require('../models')(require('../config/env').mongo_url)
#require('../lib/mongo-log')(mongoose.mongo)
async = require 'async'
Team = mongoose.model 'Team'

Team.find {}, (err, teams) ->
  return err if err

  async.mapSeries teams, (team, next) ->
    return next(null, team) if team.peopleIds.length is 0  # skip empty
    # return next(null, team) if team.slug is team.slugBase
    # return next(null, team) # don't modify right now

    if team.name == 'ヽ( ´¬`)ノ'
      old = team.slug
      team.slug = 'waving'
      team.save (err) ->
        console.log "#{old.red} -> #{team.slug.green} (#{team.name})"
        return next err, team
    else
      return next(null, team) # If it's not one of the odd cases, it's ok :)
  , (err, teams) ->
    console.log err if err

    console.log "#{pad 'slug'} name"
    console.log "#{pad team.slug} #{team.name}" for team in teams

    mongoose.connection.close()

pad = (s) -> ('                    ' + s).slice(-20)
