var env = require('../config/env');

module.exports = function(app) {
  var io = app.ws;
  io.sockets.on('connection', function(client) {
    client.on('join', function(room){
      client.join(room);
      // If the user wants to get twitter messages we also want to send
      // the @node_knockout ones separate
      if (room === 'twitter') {
        client.join('usertwitter');
      }
      switch(room) {
        case 'irc':
          setupIrc(client);
          break;
        case 'twitter':
          setupTwitter(client);
          break;
        case 'github':
          setupGithub(client);
          break;
        case 'deploy':
          setupDeploys(client);
          break;
      }
    });
  });

  // IRC
  var setupIrc = (function() {
    if (!env.irc) {
      return false;
    }
    var irc = require('irc');
    var ircClient = new irc.Client(env.irc.server, env.irc.username, {
      'channels': env.irc.channels
    });
    ircClient.addListener('message', function (from, to, message) {
      var ircMessage = {'from': from, 'message': message};
      backlog.add(ircMessage);
      io.sockets.to('irc').emit('irc', ircMessage);
    });
    var backlog = new Backlog('irc', 30);
    return function(client) {
      backlog.getAll().forEach(function(irc) {
        client.emit('irc', irc);
      });
    };
  })();

  // Twitter
  var setupTwitter = (function() {
    if (!env.secrets.twitterUser) {
      return false;
    }
    var TwitterNode = require('twitter-node').TwitterNode;

    var stickyUser = '148922824'; // @node_knockout

    var searchBacklog = new Backlog('twitter', 30);
    var userBacklog = new Backlog('usertwitter', 2);
    var twitterSearchStream = new TwitterNode({
      'user': env.secrets.twitterUser.user
      , 'password': env.secrets.twitterUser.password
      , 'track': ['node knockout', 'nodeknockout', 'node_knockout', 'nodeko', '#nko']
      , 'follow': [stickyUser]
    });

    twitterSearchStream.on('tweet', function(tweet) {
      if (tweet.user.id_str === stickyUser) {
        userBacklog.add(tweet);
        io.sockets.to('usertwitter').emit('usertweet', tweet);
      } else {
        searchBacklog.add(tweet);
        io.sockets.to('twitter').emit('tweet', tweet);
      }
    });
    twitterSearchStream.on('error', function() {});
    twitterSearchStream.stream();

    return function(client) {
      searchBacklog.getAll().forEach(function(tweet) {
        client.emit('tweet', tweet);
      });
      userBacklog.getAll().forEach(function(tweet) {
        client.emit('usertweet', tweet);
      });
    };
  })();

  // Github
  var setupGithub = (function() {
    var backlog = new Backlog('github', 30);

    app.events.on('commit', function(commit, team) {
      var commitMessage =
        { team:
          { name: team.entry.name
          , by: team.name
          , slug: team.slug
          , screenshot: team.screenshot
          , url: team.entry.url }
        , message: commit.message.trim()
        , author: commit.author.username
        , timestamp: new Date(Date.parse(commit.timestamp)) };
      backlog.add(commitMessage);
      io.sockets.to('commit').emit('commit', commitMessage);
    });

    return function(client) {
      backlog.getAll().forEach(function(commit) {
        client.emit('commit', commit);
      });
    };
  })();

  // Deploys
  var setupDeploys = (function() {
    var backlog = new Backlog('deploy', 30);

    app.events.on('deploy', function(deploy, team) {
      var deployMessage =
        { team:
          { name: team.entry.name
          , by: team.name
          , slug: team.slug
          , screenshot: team.screenshot
          , url: team.entry.url }
        , platform: deploy.platform
        , updatedAt: deploy.updatedAt };
      backlog.add(deployMessage);
      io.sockets.to('deploy').emit('deploy', deployMessage);
    });

    return function(client) {
      backlog.getAll().forEach(function(deploy) {
        client.emit('deploy', deploy);
      });
    };
  })();
}

var redis = require('redis');
var url = require('url');

var redisClient;
if (process.env.REDISCLOUD_URL) {
  var redisURL = url.parse(process.env.REDISCLOUD_URL);
  redisClient = redis.createClient(redisURL.port, redisURL.hostname, {no_ready_check: true});
  redisClient.auth(redisURL.auth.split(":")[1]);
} else {
  redisClient.createClient()
}

var Backlog = function(key, maxCount) {
  key = 'dashboard-'+key;

  var cache = [];
  redisClient.get(key, function(err, result) {
    if (result) {
      cache = JSON.parse(result);
    }
	});
  return {
    'getAll': function() {
      return cache;
    }
    , 'add': function(data) {
      cache.push(data);
      if (cache.length > maxCount) {
        cache = cache.slice(cache.length-maxCount);
      };
			redisClient.set(key, JSON.stringify(cache));
    }
  }
};
