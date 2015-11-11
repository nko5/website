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
        "/public/javascripts/vendor/jquery.transloadit2.js",
        '/public/javascripts/vendor/jquery.ba-hashchange.js',
        "/public/javascripts/vendor/bootstrap.js",
        '/public/javascripts/vendor/jquery.infinitescroll2.js',
        "/public/javascripts/vendor/jquery.stars.coffee",
        '/public/javascripts/vendor/jquery.border-image.js',
        '/public/javascripts/vendor/jquery.scrollTo.js',
        '/public/javascripts/vendor/jquery.transform.light.js',
        '/public/javascripts/vendor/jquery-ujs.js',
        '/public/javascripts/vendor/jquery.autosize.min.js',
        '/public/javascripts/vendor/countdown.js',
        '/public/javascripts/vendor/md5.js',
        '/public/javascripts/vendor/moment.js',
        '/public/javascripts/vendor/polyfills.js',
        '/public/javascripts/vendor/underscore-1.3.3.js',
        '/public/javascripts/vendor/jade.runtime.js',
        '/public/javascripts/vendor/ekko-lightbox.coffee',
        "/public/javascripts/2013/tumblr.js",
        "/public/javascripts/2013.coffee",
        "/public/javascripts/2013/teams.coffee",
        "/public/javascripts/2013/people.coffee",
        "/public/javascripts/2013/judges.coffee",
        "/public/javascripts/2013/prizes.coffee",
        "/public/javascripts/2013/jobs.coffee",
        "/public/javascripts/2013/votes.coffee",
        "/public/javascripts/2013/recent-deploy.js"
        // '/public/javascripts/2013/websocket.coffee'
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
        "/public/javascripts/vendor/jquery.stars.coffee",
        '/public/javascripts/vendor/polyfills.js',
        // '/public/javascripts/2012/watchmaker.js',
        '/public/javascripts/2012.coffee',
        '/public/javascripts/2012/dashboard.js',
        '/public/javascripts/2012/index.coffee',
        '/public/javascripts/2012/judges.coffee',
        '/public/javascripts/2012/login.coffee',
        '/public/javascripts/2012/nodeconf.js',
        '/public/javascripts/2012/people.coffee',
        '/public/javascripts/2012/teams.coffee'
        // '/public/javascripts/2012/websocket.coffee'
      ]
    },
    css: {
      '2013': [
        "/public/stylesheets/vendor/bootstrap.css",
        "/public/stylesheets/vendor/bootstrap-vertical-tabs.css",
        "/public/stylesheets/2013.styl",
        "/public/stylesheets/2013/landing-animations.css"
      ],
      "2012": [
        "/public/stylesheets/vendor/bootstrap.css",
        '/public/stylesheets/2012.styl'
      ]
    },
    jst: {}
  }
});
