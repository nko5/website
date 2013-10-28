env = require './env'

# https://github.com/fictorial/linode-api
module.exports = new(require('linode-api').LinodeClient)(env.secrets.linode)
