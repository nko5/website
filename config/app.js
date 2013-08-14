var express = require('express')
  , auth = require('mongoose-auth')
  , env = require('./env')
  , util = require('util')
  , port = env.port
  , secrets = env.secrets
  , EventEmitter = require('events').EventEmitter
  , Stats = require('../models/stats')
  , Twitter = require('../models/twitter')
  , ratchetio = require('ratchetio');
require('jadevu');


// express
var app = module.exports = express();

// some paths
app.paths = {
  public: __dirname + '/../public',
  views: __dirname + '/../views'
};

// uncaught error handling
ratchetio.handleUncaughtExceptions(secrets.rollbar);

process.on('uncaughtException', function(e) {
  util.debug(e.stack.red);
});


// utilities & hacks
require('colors');
require('../lib/render2');
require('../lib/underscore.shuffle');
require('../lib/regexp-extensions');
app.dynamicHelpers = require('../lib/dynamic-helpers');

flash = require("connect-flash");

// events
app.events = new EventEmitter();

// db
app.db = require('../models')(env.mongo_url);
app.db.app = app;  // sooo hacky

// stats (kinda hacky)
app.stats = new Stats(app.db, function(err) {
  if (err) throw err;
});
app.stats.on('change', function(stats) {
  app.events.emit('updateStats', stats);
});

// twitter
app.twitter = new Twitter(secrets.twitterUser)


// state (getting pretty gross)
app.disable('pre-registration');  // just the countdown
app.enable('registration');       // months beforehand
app.disable('pre-coding');        // week beforehand
app.disable('coding');            // coding + several hours before
app.disable('voting');            // after
app.disable('winners');        // after winners are selected

app.configure(function() {
  var assetManager = require('./assetmanager')(app);

  app.use(express.compress());
  app.use(assetManager);
  app.locals({ assetManager: assetManager });

  app.use(flash());
});

app.configure('development', function() {
  app.use(express.static(app.paths.public));
  require('../lib/mongo-log')(app.db.mongo);
});
app.configure('production', function() {
  app.use(express.static(app.paths.public, { maxAge: 1000*60*5 }));
  app.use(function(req, res, next) {
    return next();
    if (req.connection.remoteAddress !== '127.0.0.1' && req.headers.host !== 'nodeknockout.com')
      res.redirect('http://nodeknockout.com' + req.url);
    else
      next();
  });
});

app.configure(function() {
  var RedisStore = require('connect-redis')(express);

  // setup redis client
  var redis = require('redis');
  var url = require('url');

  var redisClient;
  if (process.env.REDISCLOUD_URL) {
    var redisURL = url.parse(process.env.REDISCLOUD_URL);
    redisClient = redis.createClient(redisURL.port, redisURL.hostname, {no_ready_check: true});
    redisClient.auth(redisURL.auth.split(":")[1]);
  } else {
    redisClient = redis.createClient()
  }

  // cookies and sessions
  app.use(express.cookieParser());
  app.use(express.session({
    secret: secrets.session,
    store: new RedisStore({ client: redisClient}),
    cookie: { path: '/', httpOnly: true, maxAge: 1000*60*60*24*28 }
  }));

  app.use(express.bodyParser());
  app.use(express.methodOverride());

  // hacky solution for post commit hooks not to check csrf
  app.use(require('../controllers/commits')(app));
  app.use(require('../controllers/deploys')(app));

  // csrf protection
  app.use(express.csrf());
  app.use(function(req, res, next) {
    if (req.body) delete req.body._csrf;
    next();
  });

  // auth middleware needs to be pretty high up here
  app.use(auth.middleware());

  // helpers
  auth.helpExpress(app);
  require('../helpers')(app);

  app.use(express.logger());
  app.use(app.router);

  // error handling
  app.use(function(req, res, next){ // If it arrives here, it's because it didn't matched with the rest
    res.status(404);
    if (req.accepts('html')) {
      res.render2('errors/404', { status: 404 });
      return;
    }
    if (req.accepts('json')) {
      res.send({ error: 'Not found' });
      return;
    }
    res.type('txt').send('Not found');
  });

  // var ratchetErrorHandler = ratchetio.errorHandler(); No key for this thing around here  
  // app.use(function(err, req, res, next) {
  //   if (typeof(err) !== 'number') {
  //     ratchetErrorHandler(err, req, res, next);
  //   } else {
  //     next(err, req, res);
  //   }
  // });

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
  });

  app.set('views', app.paths.views);
  app.set('view engine', 'jade');
});

// helpers
auth.helpExpress(app);
require('../helpers')(app);

// express 3 requires instantiating a http.Server to attach socket.io to
var server = require('http').createServer(app)
app.ws = require('socket.io').listen(server);
server.listen(port);

app.ws.set('log level', 1);
app.ws.set('browser client minification', true);

app.on('listening', function() {
  require('util').log('listening on ' + ('0.0.0.0:' + port).cyan);

  // if run as root, downgrade to the owner of this file
  if (env.production && process.getuid() === 0)
    require('fs').stat(__filename, function(err, stats) {
      if (err) return util.log(err)
      process.setuid(stats.uid);
    });
});
