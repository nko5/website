node.js knockout deploy check-ins
---------------------------------

So, we need to keep track of your deploys for lots of different reasons.
Because we want to be as platform-agnostic as possible, we now have this fancy
module that will ping the competition website whenever you deploy.

Installation
============

Add `nko` to the dependencies section of your package.json:

    "dependencies": {
      "nko": "*",
      "other-awesome-stuff": "2.1.4"
    }

After that, `npm install`.

Usage
=====

Just require it somewhere in your normal execution path. We recommend at the
top of your `server.js`:

    require('nko')(secret);

The `secret` parameter is available on [your team page] (make sure you're
signed in to see it). It's tied to just your team, so don't share it with
others unless you want them hijacking your deploys.

If for whatever reason, you want to know when we've recorded the deploy, you
can pass an optional callback as the second parameter:

    require('nko')('correct horse battery staple', function(err, res) {
      if (err) throw err
      res.on('data', function(d) { console.log(d.toString()); });
    });

__Important: Not seeing your deploy count rising? Maybe here is why:

* The module will only ping us if the `NODE_ENV` environment
variable is set to `production`.__ If you're not seeing your deploy get
recorded, make sure that's set correctly. 

* If you happen to have
`NODE_ENV` set to `production` on your development machine, no worries: we'll
be making sure the source IP address and if <teamslug>.2013.nodeknockout.com accepts a GET request before recording a deploy.

* It will be only considered valid if after 5 seconds of the deploy, the app is still running.



Problems?
=========

As always, you can contact us at [all@nodeknockout.com] or [@node_knockout].
You can also try checking the [issue tracker].

[your team page]: http://nodeknockout.com/teams/mine
[all@nodeknockout.com]: mailto:all@nodeknockout.com
[@node_knockout]: http://twitter.com/node_knockout
[issue tracker]: https://github.com/nko2/website/issues
