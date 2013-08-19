var util = require('util')
  , app = require('../config/app')

app.use(function (err, req, res, next) { 
  if (typeof(err) === 'number'){
    return res.render2('errors/' + err, { status: err });
  }
  if (typeof(err) === 'string'){
    err = Error(err);
  }  
  if (err) {
    return res.render2('errors/' + err.status, { status: err.status });
  }

  console.error(err.stack);
  res.render2('errors/500', { error: err });
})

