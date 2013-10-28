# creates a deploy key on the team's joyent box and adds it to the team's
# github repo

module.exports = setupDeployKey = (options, next) ->
  team = options.team
  githubAuth = options.githubAuth

  # TODO setup deploy key

  next()
