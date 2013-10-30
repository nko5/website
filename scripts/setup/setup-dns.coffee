# creates an A record on linode that points #{slug}.2013.nodeknockout.com to
# the team's ip address

linode = require('../../config/linode')

module.exports = setupDNS = (options, next) ->
  team = options.team

  # linode.call 'domain.list', (err, res) -> console.log(res)

  console.log team.slug, 'creating dns entry'
  linode 'resource.create'
    type: "A"
    name: "#{team}.2013.nodeknockout.com"
    target: team.ip
  , next
