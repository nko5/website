env = require './env'

domainId = 113572 # nko domain id
client = new(require('linode-api').LinodeClient)(env.secrets.linode)

# https://github.com/fictorial/linode-api
module.exports = linode = (action, params, next) ->
  unless next?
    next = params
    params = {}
  params.domainId = domainId
  client.call "domain.#{action}", params, next
