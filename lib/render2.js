var http = require('http')
  , util = require('util')
  , res = http.ServerResponse.prototype;

res.render2 = function() {
  util.log('Rendering ' + arguments[0]);
  this.locals({ view: arguments[0] });
  return this.render.apply(this, arguments);
};
