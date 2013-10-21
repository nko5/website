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
        "/public/javascripts/vendor/jquery.transloadit2.js",
        "/public/javascripts/vendor/bootstrap.js",
        "/public/javascripts/tumblr.js",
        "/public/javascripts/2013.coffee",
        "/public/javascripts/teams.coffee",
        "/public/javascripts/people.coffee",
        "/public/javascripts/judges.coffee"
      ],
      "2012": [
        '/public/javascripts/polyfills.js',
        '/public/javascripts/vendor/json2.js',
        '/public/javascripts/vendor/jquery-1.7.2.js',
        '/public/javascripts/vendor/jquery.ba-hashchange.js',
        '/public/javascripts/vendor/jquery.border-image.js',
        '/public/javascripts/vendor/jquery.infinitescroll.js',
        '/public/javascripts/vendor/jquery.keylisten.js',
        '/public/javascripts/vendor/jquery.pjax.js',
        '/public/javascripts/vendor/jquery.redraw.js',
        '/public/javascripts/vendor/jquery.transform.light.js',
        '/public/javascripts/vendor/jquery.transloadit2.js',
        '/public/javascripts/vendor/md5.js',
        '/public/javascripts/vendor/moment.js',
        '/public/javascripts/vendor/underscore-1.3.3.js',
        '/public/javascripts/watchmaker.js',
        '/public/javascripts/application.coffee'
      ]
    },
    css: {
      '2013': [
        "/public/stylesheets/vendor/bootstrap.css",
        "/public/stylesheets/2013.styl",
        "/public/stylesheets/fontello.css"
      ],
      "2012": [
        "/public/stylesheets/vendor/bootstrap.css",
        '/public/stylesheets/fontello.css',
        '/public/stylesheets/application.styl'
      ]
    },
    jst: {}
  }
});

