# creates an A record on linode that points #{slug}.2015.nodeknockout.com to
# the team's ip address

linode = require('../../config/linode')

module.exports = setupDNS = (options, next) ->
  team = options.team

  if team.linode?.ResourceID
    console.log team.slug, 'dns already setup'
    return next()

  console.log team.slug, 'creating dns entry'
  linode 'resource.create',
    type: "A"
    name: "#{team}.2015.nodeknockout.com"
    target: team.ip
  , (err, res) ->
    return next(err) if err?
    team.linode = res
    team.save (err) -> next(err)
