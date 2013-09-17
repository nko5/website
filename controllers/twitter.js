var util = require('util')
  , app = require('../config/app');


app.get('/twitter/:username', function(req, res){
  console.log(req.params.username);
  if(!req.params){
    return res.send(null);
  }
  app.twitter.get( 'users/show'
  , { screen_name: req.params.username }
  , function(err, userData) {
      if (err) {
        res.send(null);
      }
        res.send(userData); 
  })


});


