var env = require('./env');
global.nap = require('nap');

nap({
  publicDir: '/public',
  mode: env.node_env === 'production' ? 'production' : 'development',
  assets: {
    js: {
      '2013': [
        "/public/javascripts/vendor/bootstrap.js",
        "/public/javascripts/2013.coffee"
      ]
    },
    css: {
      '2013': [
        "/public/stylesheets/vendor/bootstrap.css",
        "/public/stylesheets/2013.styl"
      ]
    },
    jst: {}
  }
});

