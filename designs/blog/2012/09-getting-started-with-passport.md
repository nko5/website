_This is the 9th in a series of posts leading up to [Node.js Knockout][] on
using [Passport][].  This post was written by [Node Knockout judge][] and
[Passport][] creator Jared Hanson._

[Node.js Knockout]: http://nodeknockout.com
[Passport]: http://passportjs.org/
[Node Knockout judge]: http://nodeknockout.com/people/5085e10ff3d3beff1200006b

[Passport](http://passportjs.org/) is middleware for Node.js that makes
implementing authentication quick and easy.  Authentication can take a
variety of forms, including a username and password, [OpenID](http://openid.net/),
[OAuth](http://oauth.net/), and [BrowserID](https://developer.mozilla.org/en-US/docs/Persona).

Many users prefer to sign in using an existing social network account, such as
Facebook or Twitter.  In this example, we'll implement support for signing in
with Twitter.

## Install Dependencies

    $ npm install express
    $ npm install passport
    $ npm install passport-twitter
    $ npm install connect-ensure-login

We'll be building on the simple [Express](http://expressjs.com/) application
that [TJ Holowaychuk](http://tjholowaychuk.com/) built in an earlier
[post](http://blog.nodeknockout.com/post/34180474119/getting-started-with-express).
Passport has a modular architecture that breaks authentication mechanisms into
strategies (in this case Twitter) which are distributed separately, keeping the
core lightweight.  We'll also use [connect-ensure-login](https://github.com/jaredhanson/connect-ensure-login)
to protect authenticated routes.

## Authentication Checklist

The following three items need to be checked off to implement authentication.

1. Configure session middleware
2. Configure authentication strategies
3. Add authentication routes

We'll cover each of them, starting from outside in: routes to middleware.

## Authenticated Routes

Let's add a route to `/account`, which shows a person their account details.

    app.get('/account',
      ensureLoggedIn('/login'),
      function(req, res) {
        res.send('Hello ' + req.user.username);
      });

In order to access this page, a user will need to be logged in.  `ensureLoggedIn`
will verify that this is the case, and if not, redirect the user to the login
page.  Which looks like:

    app.get('/login',
      function(req, res) {
        res.send('<html><body><a href="/auth/twitter">Sign in with Twitter</a></body></html>');
      });

Simple.  The user can just click a link and sign in with Twitter.  Which brings us
to the next step in our implementation:

## Configuring Twitter Authentication

Twitter authentication uses OAuth, which means you'll need to obtain a key and
secret from Twitter.  If you don't have one yet, you'll need to [register](https://dev.twitter.com/apps)
your application with Twitter.

Once you have keys, configure the Twitter authentication strategy:

    var TWITTER_CONSUMER_KEY = "INSERT_KEY_HERE";
    var TWITTER_CONSUMER_SECRET = "INSERT_SECRET_HERE";

    passport.use(new TwitterStrategy({
        consumerKey: TWITTER_CONSUMER_KEY,
        consumerSecret: TWITTER_CONSUMER_SECRET,
        callbackURL: "http://127.0.0.1:3000/auth/twitter/callback"
      },
      function(token, tokenSecret, profile, done) {
        // NOTE: You'll probably want to associate the Twitter profile with a
        //       user record in your application's DB.
        var user = profile;
        return done(null, user);
      }
    ));

The function supplied to the strategy is known as a "verify callback".  Verify
callbacks receive credentials as arguments (in this case the token, tokenSecret
and profile), which are used to locate and return user records.  The `user`
instance returned will be logged in and set on the request at `req.user`.

In most applications, you'll want to associate the Twitter account with a user
record in your application's database.  This allows you to also associate other
accounts (such as Facebook) with the same user, allowing them to log in using
either service.  To keep this example simple, we will use the profile data
directly, avoiding the need for database associations.

The OAuth protocol used by Twitter involves a two-step process using redirects
to exchange and verify tokens.  This is fairly complicated, but Passport
middleware makes it easy.  Just drop in the following routes:

    app.get('/auth/twitter', passport.authenticate('twitter'));
    app.get('/auth/twitter/callback', passport.authenticate('twitter', { successReturnToOrRedirect: '/', failureRedirect: '/login' }));

The first route will begin an OAuth transaction and redirect the user to Twitter.
Once signed in, Twitter will redirect the user back to our application and
Passport will return them to the original page they requested (or '/').

Easy enough, but there's still one more thing to do:

## Configure Sessions

In order to keep track of the fact that a user has logged in, an application
needs to implement support for sessions.  Do that by using Express' built-in
cookie parser and session middleware, and initializing Passport.

    app.use(express.cookieParser());
    app.use(express.session({ secret: 'keyboard cat' }));
    app.use(passport.initialize());
    app.use(passport.session());

When a user logs in, the user record is stored in the session in order to
maintain the logged-in state as she browses your site.  Serialization and
deserialization functions are supplied to control this process.

    passport.serializeUser(function(user, done) {
      done(null, user);
    });

    passport.deserializeUser(function(obj, done) {
      done(null, obj);
    });

As noted above, if you are creating user records in your own database, you
can serialize just the user ID to minimize the amount of data stored in the
session.  For simplicity, the entire record is serialized in this example.

## Wrapping Up

That's it, people can now sign in with Twitter!  The complete code for this
example is available as a [gist](https://gist.github.com/3989193).

If you take authentication further, consult [guide](http://passportjs.org/guide/)
for in-depth details on how Passport operates.  Additionally, if you need to
implement API authentication, see Passport's sister projects: [OAuthorize](https://github.com/jaredhanson/oauthorize)
and [OAuth2orize](https://github.com/jaredhanson/oauth2orize)