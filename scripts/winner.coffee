require 'colors'
env = require '../config/env'
mongoose = require('../models')(env.mongo_url)

slug = process.argv[2]

exit = (msg) ->
  console.error(msg.red) if msg
  process.exit(-1)

unless slug
  exit("Usage: coffee winners.coffee winning-team-slug")
  process.exit()


console.log "Creating winner markdown for #{process.argv[2]}"

Team = mongoose.model 'Team'

Team.findOne slug: slug, (err, team) ->
  return exit(err) if err
  console.log """
    # Category
    <a href="#{team.entry.url}"><img src="#{team.screenshot}"></a>
    ## [#{team.entry.name}](#{team.entry.url})
    #### by [#{team.name}](/teams/#{team})

    #{team.entry.description}

    <div style="clear:both;"></div>
    """
  mongoose.connection.close()
