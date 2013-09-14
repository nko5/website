var Twit = require('twit')
  , secrets = require('./../config/secrets.js')

var T = new Twit({
    consumer_key: secrets.twitterAPI.consumer_key
  , consumer_secret: secrets.twitterAPI.consumer_secret
  , access_token: secrets.twitterAPI.access_token_key
  , access_token_secret:  secrets.twitterAPI.access_token_secret
})


var getUserData = module.exports = function (twitterHandle, cb) {
  T.get( 'users/show'
    , { screen_name: twitterHandle }
    , function(err, userData) {
        if (err) {cb(err, null)}
        cb(null, userData)  
    })
}
