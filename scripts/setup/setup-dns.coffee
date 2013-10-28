# creates an A record on linode that points #{slug}.2013.nodeknockout.com to
# the team's ip address

module.exports = setupDNS = (options, next) ->
  team = options.team

  # TODO setup dns

  next()
