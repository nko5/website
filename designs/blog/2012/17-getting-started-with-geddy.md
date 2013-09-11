_This is the 17th in a series of posts leading up to [Node.js Knockout][1] on
getting started with [Geddy][2] This post was written by [Geddy][2]
contributor and [Node Knockout Judge][3] Daniel Erickson. It is cross-posted
on the [Geddy wiki][4]._

[1]: http://nodeknockout.com/
[2]: http://geddyjs.org/
[3]: http://nodeknockout.com/people/509c670a7e61d0c56e00001d
[4]: https://github.com/mde/geddy/wiki/Getting-started-with-Geddy,-Socket.io,-and-Authentication

### Intro

I’ve had a few people ask me to write a quick guide to getting started with
authentication and realtime events with Geddy. These are both really amazing
new features so I thought I’d oblidge.

### Installing Geddy

Installing Geddy is as easy as installing any other global node module:

    $ npm install -g geddy

This will get you the latest version of Geddy and all of it’s (minimal)
dependencies.

### Starting a new project

Likewise, starting a new project is pretty easy too:

    $ geddy app -rt node_ko

You’ll notice that `-rt` option in there - that tells the app generator to
include the socket.io integration code in your newly generated app.

### Adding user authentication:

Setting up local, Facebook, and Twitter authentication for your users is also
very simple, just `cd` into your project and type:

    $ geddy auth

This will generate a User model for us, and it will set up all the routes and
views that your users will need to log in. In order for the generated code to
work, your app will have to know your client application keys for each of the
supported authentication apis.

You'll need to add the settings for Passport in your app's environment.js
file. That includes the redirect locations for after an auth failure or
success, and the OAuth keys for your app. The setting will look something like
this:

    passport: {
      successRedirect: '/'
    , failureRedirect: '/login'
    , twitter: {
        consumerKey: 'XXXXXXX'
      , consumerSecret: 'XXXXXXX'
      }
    , facebook: {
        clientID: 'XXXXXXX'
      , clientSecret: 'XXXXXXX'
      }
    }

### Adding some scaffolding

Next we’ll want to scaffold out a resource for us to use. Lets go ahead and
create a messages resource:

    $ geddy scaffold -rt message body

This will generate a Message model, a messages controller, some message views,
and all of the routes needed to perform the basic CRUD actions. Because we
used the `-rt` option, it will also make our models available on the front end
and create a socket.io channel so that we can listen for model related
lifecycle events on the front end.

### Running the app

If you’re running your app locally, all you’ll need to do is run it with the
`geddy` command:

    $ geddy

If you’re running your app on a platform that does not allow you to use global
modules, you’ll need to create a `server.js` file in your app’s root directory
with these contents:

    //web: node node_modules/geddy/bin/cli.js
    var geddy = require('geddy');

    geddy.start({
      environment: 'production'
    });

### Customizing the app

First, lets make sure that messages endpoints are secure, we only want logged
in users to be able to view, edit, and remove messages.

Open up your app/controllers/messages.js file and add this:

    this.before(require(‘../helpers/passport’).requireAuth);

This will require that there is a logged in user before performing an action
in the messages controller.

Next, lets make sure that our users are redirected to the right place after
they log in. Open up your environment.js file and change
`passport.successRedirect` to `/messages`. This will redirect users to the
messages index route after they successfully log in.

### Test out your app

Open up <http://localhost:4000/> and check out your app. Log in with one of the
links on the home page, check out the realtime stuff by opening two browser
windows, signing into both of them, and adding a message in one.

### Things you can try to learn more

* create a new message via ajax so it feels more like a chat room
* display the date of the message instead of the id
* make the views a bit prettier

### Want to know more?

* Check out the documentation at http://geddyjs.org/documentation
* Ask your questions on the mailing list
* Hop on IRC and get help if you need it: #geddy on freenode
