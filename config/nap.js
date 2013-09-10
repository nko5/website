var env = require('./env');
global.nap = require('nap');

console.log("NAP CURRENT DIRECTORY:");
console.log(process.cwd());

nap({
  publicDir: '/public',
  mode: env.node_env === 'production' ? 'production' : 'development',
  assets: {
    js: {
      '2013': [
        "/public/javascripts/vendor/jquery-1.10.2.min.js",
        "/public/javascripts/vendor/bootstrap.js",
        "/public/javascripts/tumblr.js",
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

