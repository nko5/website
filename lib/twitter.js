var Twit = require('twit')
  , secrets = require('./../config/secrets.js')

var T = new Twit({
    consumer_key: secrets.twitterUser.consumer_key
  , consumer_secret: secrets.twitterUser.consumer_secret
  , access_token: secrets.twitterUser.access_token_key
  , access_token_secret:  secrets.twitterUser.access_token_secret
})


var getUserData = function (twitterHandle, cb) {
  T.get( 'users/show'
    , { screen_name: twitterHandle }
    , function(err, userData) {
        if (err) {cb(err, null)}
        cb(null, userData)  
    })
}

module.exports = {
  getUserData: getUserData
}