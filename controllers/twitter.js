var util = require('util')
  , app = require('../config/app');

app.get('/twitter/:username', function(req, res){
  if (!req.params || !req.params.username) {
    return res.next();
  }
  app.twitter.get( 'users/show'
  , { screen_name: req.params.username }
  , function(err, userData) {
      if (err) { return res.next(err); }
      res.send(userData);
  })
});
