var env = require('./env')
  , coffee = require('coffee-script')
  , stylus = require('stylus')
  , assetManager = require('connect-assetmanager');

module.exports = function(app) {
  return assetManager({
    js: {
      route: /\/javascripts\/all-[a-z0-9]+\.js/,
      path: __dirname + '/../public/javascripts/',
      dataType: 'javascript',
      debug: true, //env.node_env === 'development',
      preManipulate: {
        '^': [
          function(src, path, index, isLast, callback) {
            callback(src.replace(/#socketIoPort#/g, env.port));
          }
          , function(src, path, index, isLast, callback) {
            if (/\.coffee$/.test(path)) {
              callback(coffee.compile(src));
            } else {
              callback(src);
            }
          }
        ]
      },
      files: [ // order matters here
        'polyfills.js',
        'vendor/hoptoad-notifier.js',
        'vendor/hoptoad-key.js',
        'vendor/json2.js',
        'vendor/jquery-1.7.2.js',
        'vendor/jquery.ba-hashchange.js',
        'vendor/jquery.border-image.js',
        'vendor/jquery.infinitescroll.js',
        'vendor/jquery.keylisten.js',
        'vendor/jquery.pjax.js',
        'vendor/jquery.redraw.js',
        'vendor/jquery.transform.light.js',
        'vendor/jquery.transloadit2.js',
        'vendor/md5.js',
        'vendor/moment.js',
        'vendor/underscore-1.3.3.js',
        'watchmaker.js',
        'application.coffee',
        '*'
      ]
    },
    css: {
      route: /\/stylesheets\/all-[a-z0-9]+\.css/,
      path: __dirname + '/../public/stylesheets/',
      dataType: 'css',
      debug: env.node_env === 'development',
      preManipulate: {
        '^': [
          function(src, path, index, isLast, callback) {
            if (/\.styl$/.test(path)) {
              stylus(src)
                .set('compress', false)
                .set('filename', path)
                .set('paths', [ __dirname, app.paths.public ])
                .render(function(err, css) {
                  callback(err || css);
                });
            } else {
              callback(src);
            }
          }
        ]
      },
      files: [ // order matters here
        'vendor/normalize.css',
        'fontello.css',
        'application.styl'
      ]
    }
  });
};
