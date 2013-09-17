var env = module.exports = {
  node_env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT) || 8003,
  mongo_url: process.env.MONGOHQ_URL || 'mongodb://localhost/nko4_development'
};

env.development = env.node_env === 'development';
env.production = !env.development;

if (env.development) {
  env.hostname = 'http://localhost:' + env.port;

  env.facebook_app_id = '167380289998508';
  env.github_app_id = 'c07cd7100ae57921a267';
  env.twitter_app_id = 'EDyM8JM1QRoRArpeXcarCA';
  try { env.secrets = require('./secrets'); }
  catch(e) { throw "secret keys file is missing. see ./secrets.js.sample."; }
  env.irc = {
	  username: 'NKOtestBot',
	  server: 'irc.bamze.net',
	  channels: ['#nodeknockout', '#node.js']
	};
} else {
  env.hostname = 'http://nodeknockout.com';

  env.facebook_app_id = '228877970485637';
  env.github_app_id = 'c294545b6f2898154827';
  env.twitter_app_id = 'EDyM8JM1QRoRArpeXcarCA';
  env.secrets = {
    facebook: process.env.FACEBOOK_OAUTH_SECRET,
    github: process.env.GITHUB_OAUTH_SECRET,
    twitter: process.env.TWITTER_OAUTH_SECRET,
    postageapp: process.env.POSTAGEAPP_SECRET,
    url2png: process.env.URL2PNG_SECRET,
    session: process.env.EXPRESS_SESSION_KEY,
    rollbar: process.env.ROLLBAR_SECRET,
    twitterUser: {
      consumer_key: process.env.TWITTER_USER_CONSUMER_KEY,
      consumer_secret: process.env.TWITTER_USER_CONSUMER_SECRET,
      access_token: process.env.TWITTER_USER_ACCESS_TOKEN_KEY,
      access_token_secret: process.env.TWITTER_USER_ACCESS_TOKEN_SECRET
    }
  };
  env.irc = {
	  username: 'MrNko',
	  server: 'irc.freenode.net',
	  channels: ['#nodeknockout', '#node.js']
	};
}
