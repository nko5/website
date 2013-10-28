# creates an A record on linode that points #{slug}.2013.nodeknockout.com to
# the team's ip address

module.exports = setupDNS = (options, next) ->
  team = options.team
  domainId = options?.linode?.domainId ? 113572 # nko domain id

  linode = require('../../config/linode')

  # linode.call 'domain.list', (err, res) -> console.log(res)

  console.log team.slug, 'creating dns entry'
  linode.call 'domain.resource.create'
    domainId: domainId
    type: "A"
    name: "#{team}.2013.nodeknockout.com"
    target: team.ip
  , next
