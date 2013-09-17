var util = require('util')
  , app = require('../config/app')
  , twitter = require('./../lib/twitter.js');


app.get('/twitter/:username', function(req, res){
  console.log(req.params.username);
  if(!req.params){
    return res.send(null);
  }
  twitter.getUserData(req.params.username, function (err, userdata) {
    if (err) {
      res.send(null);
    }
    res.send(userdata);
  })  
});


