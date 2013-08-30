var env = require('./env');
global.nap = require('nap');

nap({
  publicDir: '/public',
  mode: "production",
  assets: {
    js: {
      'new-js': [
        "/public/javascripts/vendor/bootstrap.js",
        "/public/javascripts/new-js.coffee"
      ]
    },
    css: {
      'new-styles': [
        "/public/stylesheets/vendor/bootstrap.css",
        "/public/stylesheets/new-styles.styl"
      ]
    },
    jst: {}
  }
});

