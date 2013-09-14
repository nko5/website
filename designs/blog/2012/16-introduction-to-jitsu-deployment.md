_This is the 16th in a series of posts leading up to [Node.js Knockout][1] on
using jitsu to deploy to [Nodejitsu][2] This post was written by [Nodejitsu][2]
Support Engineer [Colton Baker][3] (Southern)._

[1]: http://nodeknockout.com
[2]: http://nodejitsu.com/
[3]: https://github.com/Southern


# Introduction to Jitsu deployment

## TL;DR

    $ git clone git@github.com:nko3/[slug].git myapp
    $ cd myapp
    $ [sudo] npm install -g jitsu
    $ jitsu login # username and password provided on your NKO team page
    $ jitsu deploy


## Installing

To install Jitsu, all you have to do is run: `npm install -g jitsu`

**Hint:** If `npm` throws an error, try using `sudo npm install -g jitsu`.


## Setting up Jitsu

Once you install Jitsu, you will need to login with the password that was provided to your team by NKO. This login, and only this login, will need to be used for each team member. **NKO will not accept submissions that are under another Nodejitsu account.**

To login, use: `jitsu login`

**Hint:** If you get an error when logging in, try using one of the following:

- `jitsu conf set protocol http`
- `jitsu conf set host api.nodejitsu.com`


## Deploying

Before developing your app, you should clone the repository provided to your team by NKO. This will follow the pattern of `nko3/[slug]`. For example, if your team is named "Node Bandits", your repository would be `nko3/node-bandits`.

If you do not have access to this repository, let someone know immediately. This repository provides a skeleton of what NKO is expecting you to submit when you deploy your application.

Once you have this repository checked out, you can code your application however you see fit. Once you're done, deploy your application to our cloud by running `jitsu deploy` in the directory containing the `package.json` file that was provided by your `nko3/[slug]` repository.

**Warning:** Make sure you keep version numbers synced across team members. If a team member trying to deploy an application with version 0.0.1 while another team member has deployed 0.0.2, the server will reject the deploy.

**Remember:**

- `nko3/[slug]` should be `nko3/your-team-name`. For example, a team named "Node Bandits" would be `nko3/node-bandits`.
- You get one login for Nodejitsu per team. Use it, because your submissions won't be accepted from another account.
- Keep version numbers synced amongst your team. Using different versions could, and probably will, cause unintended effects.


## Going deeper

Jitsu has a lot of features including deploying old snapshots, getting running logs, setting environment variables, and even creating databases. More info can be found by just typing `jitsu` at the command line or in the [Nodejitsu Handbook](http://handbook.jit.su/#jitsu).


## Help

You can visit us online at our [homepage][nodejitsu homepage]. You can find out more information about Jitsu on [Github][nodejitsu/jitsu]. As always, you can also find us on IRC on [Freenode](irc://freenode.net/nodejitsu) on #nodejitsu.

[nodejitsu homepage]: http://nodejitsu.com
[nodejitsu/jitsu]: https://github.com/nodejitsu/jitsu
