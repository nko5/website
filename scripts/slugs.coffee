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
    # return next(null, team) # don't modify right now

    if team.peopleIds.length is 0
      console.log "EMPTY TEAM - nodeknockout.com/teams/#{team.slug} (#{team.name})"
      return next(null, team)

    # don't change any team that's already being setup
    return next(null, team) if team.setup?.status

    changes = 
      "-1": "theteam"
      "3": "heart"
      "-3": "annteens"
      "-4": "tigercat"
      "-2": "hiten" 
      "apple-pie": "religion"
      "hello-world": "console-log"
      "hashtaghashtag": "db2"
      "david-kamm": "wittier-team-name"
      "vancouver-gastown": "xuka"  
      "father-son": "world-hello"
      "204-no-content": "process-nexttick"
      "streamsters-union-61": "streamsters-612"
      "bam-green-eggs-and-h": "green-eggs-and-ham"
      "node-group-tbd": "xyzzy"
      "tmp": "walbril"
      "software-niagara-tea": "niagara-team"
      "swhite": "pimps-love"
      "front-end-developers": "fed-brazil"
      "cold-brew-rocket-fue": "brew-rocket-fuel"
      "edlington": "rikoru"
      "web-scale-or-web-fai": "web-scale-or-fail"
      "rock-em-sock-em-node": "rockem-sockem"
      "dominican-node-assoc": "dominican-assoc"
      "the-idea-hacker": "the-unbeatables"
      "not-just-another-tea": "not-another-team"
      "team-awesome-1": "team-fried-chicken"
      "little-bobby-drop-ta": "bobby-drop-tables"
      "red-hot-pink-daisy-s": "red-hot-pink-daisy"
      "kansas-city-expatria": "kansas-city-expats"
      "the-flying-penguins": "the-flying-penguin"
      "tasmanian-tigers": "node-out"
      "interweb-slackers": "interweb-labs"
      "dwango": "mesolabs"
      "southern-riot": "sc-positronics"
      "streamsters-union612": "streamsters-612"
      "voxelperfect": "band-jamming"
      "alsw": "machinarium"
      "me-the-interns": "me-and-the-interns"
      "imsowitty": "axias"
      "gus-gorman-for-presi": "gus-gorman-for-prez"
      "tem-lazors": "camarinhas"
      "juggabots": "cool-ladies-gif"
      "klandestino-ab": "klandestino"
      "jedi-knights": "throw-42"
      "node-rt": "nko-analytics"
      "restort": "the-tickeros"
      "tmp-1": "fifty-five"
      "turbo-team": "nodespots"
      "parmenides": "heraclitus"
      "andrew-in-demton": "time-ghost"
      "comorichweb": "devcomo"
      "team-js": "node-ninja-turtles"
      "1999-land": "ninety-nine-land"
      "sloweak": "sloweak-quickly"
      "witty-team-name": "rock-em-sock-em"
      "strongloop": "destroyer"
      "groupon-team-tbd": "node-fire"
      "we-shall-be-oranges": "madison-ivy"
      "sprint-run": "bab"
      "amit-m": "linearity"
      "5-cent-arcade": "nickel-arcade"
      "over-9000": "brogrammers"
      "ca-god": "ca"
      "1up": "one-up"
      "7digital": "seven-digital"
      "aveiroberlinconnecti": "aveiro-berlin"
      "apprehensive-apparit": "apprehensive"
      "rde": "rome-team"
      "team-neo": "cornerstone-sys"
      "its-always-been-brok": "always-broken"
      "figure-it-out-guys": "makeshift"

    if team.name == "ヽ( ´¬`)ノ" #special that there was no slug previously
      old = team.slug
      team.slug = 'waving'
      console.log "#{old.red} -> #{team.slug.green} (#{team.name})"

    if changes[team.slug]
      old = team.slug
      team.slug = changes[team.slug]
      console.log "#{old.red} -> #{team.slug.green} (#{team.name})"

    team.setup = { status: 'ready' }

    team.save (err) -> next(err, team)
  
  , (err, teams) ->
    console.log err if err

    console.log "#{pad 'slug'} name"
    console.log "#{pad team.slug} #{team.name}" for team in teams

    mongoose.connection.close()

pad = (s) -> ('                    ' + s).slice(-20)
