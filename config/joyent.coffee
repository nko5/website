fs = require 'fs'
path = require 'path'
env = require './env'
smartdc = require 'smartdc'
fingerprint = require 'ssh-fingerprint'

{ user, key } = env.secrets.smartdc
url = 'https://us-east-1.api.joyentcloud.com'

keyPath = path.resolve(key.replace(/^\~/, process.env.HOME))
key = fs.readFileSync(keyPath, 'utf8')
publicKey = fs.readFileSync("#{keyPath}.pub", 'utf8')
keyId = fingerprint(publicKey.split(' ')[1])

module.exports = smartdc.createClient({
    sign: smartdc.privateKeySigner({
        key: key,
        keyId: keyId,
        user: user
    }),
    user: user,
    url: url
});
