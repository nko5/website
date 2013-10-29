_Getting started with [Geddy][2] This post was written by [Geddy][2]
contributor and [Node Knockout Judge][3] Daniel Erickson. It is cross-posted
on the [Geddy wiki][4]._

[1]: http://nodeknockout.com/
[2]: http://geddyjs.org/
[3]: http://nodeknockout.com/people/509c670a7e61d0c56e00001d
[4]: https://github.com/mde/geddy/wiki/Getting-started-with-Geddy,-Socket.io,-and-Authentication

### Intro

Geddy is a Web framework for Node. It lets you very quickly build scalable MVC
apps for Node.

### Installing Geddy

Install Geddy with NPM. It has a CLI, so you need to install it globally:

    $ npm install -g geddy

This will get you the latest version of Geddy and all of its (minimal)
dependencies.

### Starting a new project

Likewise, starting a new project is pretty easy too:

    $ geddy gen app node_ko

The`gen` command in the CLI is the generator command for apps and scaffolds.

### Adding user authentication:

Setting up local, Facebook, and Twitter authentication for your users is also
very simple, just `cd` into your project and type:

    $ geddy gen auth

This will generate a User model for you, and it will set up all the routes and
views that your users will need to log in. In order for the generated code to
work, your app will have to know your client application keys for each of the
supported authentication apis.

Set these values in your app's config/secrets.json file.

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

You can also customize the success/failure redirect paths for authentication in
this same file.

### Adding some scaffolding

Next we’ll want to scaffold out a resource for us to use. Lets go ahead and
create a messages resource:

    $ geddy gen scaffold message body:text

This will generate a Message model, a messages controller, some message views,
and all of the routes needed to perform the basic CRUD actions.

### Running the app

To run your app locally, cd into the directory of your generated app, and start
it up with the `geddy` command:

    $ geddy

If you prefer, you can run your app with a bundled version of Geddy rather than
a globally installed CLI. To do this, install geddy locally inside your app using NPM:

    $ npm install geddy

Then, create a new file in your project root called 'server.js' (or possibly
'app.js') to use as your startup script, and add the following to that file:

    var geddy = require('geddy');

    geddy.startCluster({
      hostname: '0.0.0.0'
      , port: process.env.PORT || '4000'
      , environment: process.env.NODE_ENV || 'development'
    });

If you're deploying to an environment that disables the native 'cluster' module
in Node (like NodeJitsu), then use the `start` method instead of `startCluster`.
This will start the Geddy server in the same process, rather than spinning up
worker processes.

### Customizing the app

First, let's make sure that messages endpoints are secure, we only want logged
in users to be able to view, edit, and remove messages.

Open up your app/controllers/messages.js file and add this:

    this.before(require(‘../helpers/passport’).requireAuth);

This will ensure that the current user is logged in before running an action on
the messages controller.

Next, lets make sure that our users are redirected to the right place after
they log in. Open up your config/secrets.json file and change
`passport.successRedirect` to `/messages`. This will redirect users to the
messages index route after they successfully log in.

### Test out your app

Start up your app, then open up <http://localhost:4000/> in a browser, and check
it out, by logging in with one of the links on the home page.

### Want to know more?

* Check out the documentation at http://geddyjs.org/documentation
* Ask your questions on the mailing list: https://groups.google.com/group/geddyjs
* Hop on IRC and get help if you need it: #geddy on freenode

