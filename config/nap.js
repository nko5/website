var env = require('./env');
var util = require('util');
global.nap = require('nap');

// TODO: put this somewhere better
process.chdir(__dirname+"/../");
// util.debug('NAP CURRENT DIRECTORY: ' + process.cwd());

nap({
  assets: {
    js: {
      '2013': [
        "/public/javascripts/vendor/jquery-1.10.2.min.js",
        "/public/javascripts/jquery.stars.coffee",
        "/public/javascripts/vendor/bootstrap.js",
        "/public/javascripts/tumblr.js",
        "/public/javascripts/2013.coffee",
        "/public/javascripts/teams.coffee"
      ]
    },
    css: {
      '2013': [
        "/public/stylesheets/vendor/bootstrap.css",
        "/public/stylesheets/2013.styl",
        "/public/stylesheets/fontello.css"
      ]
    },
    jst: {}
  }
});

