# Deploying Your Node.js App to Ubuntu

## Intro

This year, we have created an Ubuntu 12.04 (Precise) Joyent instance for every
team.

Special thanks to Joyent for providing these instances to contestants for free
during Node Knockout (through 11/31).

We have already configured each of these instances for easy deployment. If
you're lazy, or not interested in devops, all you need to do is:

    # get the code
    git clone git@github.com:nko4/<team>.git && cd ./<team>/

    # deploy it to http://<team>.2013.nodeknockout.com/
    ./deploy nko

The rest of this post will explain how we configured the Ubuntu instances for
node production deployment.

<h2 id="configuring-ubuntu">Configuring Ubuntu</h2>

All the Ubuntu configuration happens [setup-ubuntu.sh](https://github.com/nko4/website/blob/master/scripts/setup/setup-ubuntu.sh).

### Setting the hostname

    # set the hostname
    hostname=$1
    hostname $hostname
    echo "$hostname" > /etc/hostname

We set the hostname so that your server knows its name. It's not strictly
necessary, but the default was pretty ugly.

### Installing packages (including node)

    # Updating apt packages...
    apt-get update

    # Installing git...
    apt-get install -y git-core

    # Installing node...
    apt-get install -y python-software-properties python g++ make
    add-apt-repository -y ppa:chris-lea/node.js
    apt-get update
    apt-get install -y nodejs

First, we update all the packages, then install git, since it's needed for the
deploy script.

Next, we install node & npm from a package in the [manner recommended by
Joyent](https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager#ubuntu-mint-elementary-os).

### Setting NODE_ENV

    # Setting NODE_ENV=production...
    echo "export NODE_ENV=production" > /etc/profile.d/NODE_ENV.sh

`NODE_ENV` should be `production` on production deployments we add a script to
`/etc/profile.d/` to make sure that environment variable is always set.

### Setting up SSH

    # Setting up the root user .ssh/ dir...
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    touch ~/.ssh/authorized_keys ~/.ssh/known_hosts
    chmod 600 ~/.ssh/authorized_keys ~/.ssh/known_hosts

    # Authorizing the nko4 public key for ssh access...
    cat <<EOS > ~/.ssh/authorized_keys
    #### BEGIN NKO ORGANIZERS KEY
    # DO NOT REMOVE - this allows us to audit teams for cheating
    ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAu793tQ+5RP8uo9X0WRZituBPZwRgMLxyZf+4MlM2BXxizjSlUtP/gTOHTqkzlimR1r3QOTfJN9dzs6DJZsI9T6gxJB2icjYgmYn5/4lwbry0vgoWNXwqrDkWuuSy/zaQYbbZhF3wGnqwsjR3U96XYNB6hz/ugMDkFF3BLcXvqSj0oY7FN6vdWt7tQ9y4kjkFfWJNXewshxJs8DNXqbolGqo+jvXrbq+Uj2faPKUO9rijZzmaNdKW7CX3PQl0JFWFqefKhQlyCQMoBZ47zcU79jfhYrCfd7+DIDPYAxERotGn8T+qKZbmbWPXFJ5xnFfmI6AYpBtMFeWnGol5B/CNJw== nko4
    #### END NKO ORGANIZERS KEY
    EOS

    # Adding github.com to ~/.ssh/known_hosts...
    cat <<EOS >> ~/.ssh/known_hosts
    github.com,207.97.227.239 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
    EOS

We create the ssh dir and make sure it has proper permissions. Then we add
some recognized keys:

* We add the Node Knockout organizers key to ensure that the organizers have
  access to the box, so they can audit that no unauthorized code modifications
  happen during the competition.
* We add the github public key so that there is no prompting when the deploy
  script connects to github to fetch the code.

### Setting up the deploy user

    # Setting up the deploy user...
    id deploy || useradd -U -m -s /bin/bash deploy

    # Setting up the deploy user .ssh/ dir...
    deploy_home=/home/deploy
    cp -r ~/.ssh $deploy_home/.ssh
    chown -R deploy $deploy_home/.ssh

Rather than run the server as root, we'll run it as the deploy user.

First, we create the user. The `id deploy ||` part ensures that we don't try
and create a `deploy` user if one already exists.

Second, we setup the ssh directory for the deploy user in the same way as we
did for the root user.

### Keeping the server running with `runit`

We use [runit](http://smarden.org/runit/) to keep your server running if it
crashes or the instance reboots.

#### Installing `runit`

    # Setting up runit...
    apt-get install -y runit

#### Creating a `serverjs` service for `runit`

    # Setting runit to run server.js...
    mkdir -p /etc/service/serverjs/log

    cat <<EOS > /etc/service/serverjs/run
    #!/bin/sh
    exec 2>&1
    . /etc/profile
    . $deploy_home/.profile
    exec node $deploy_home/current/server.js
    EOS
    chmod +x /etc/service/serverjs/run

`runit` creates a service monitor for every directory in `/etc/service`. To
get started, we create a directory there for `serverjs`.

Then we create a `run` script in the `serverjs` directory that tells `runit`
what to do to start the service.

Our run script does a couple things.

1. It loads `/etc/profile` and `$deploy_home/.profile` primarily so that any
   environment variables that people add are passed through to the server.
   (Remember `NODE_ENV=production` from earlier?)
2. It starts the server: `node $deploy_home/current/server.js`

As you can see, with `runit` you start your server just like you normally
would and it handles all the monitoring automatically.

#### Logging with `runit`

    # Setting up runit logging...
    mkdir -p $deploy_home/shared/logs/server

    cat <<EOS > /etc/service/serverjs/log/run
    #!/bin/sh
    exec svlogd -tt $deploy_home/shared/logs/server
    EOS
    chmod +x /etc/service/serverjs/log/run

`runit` also has some nice logging abilities built-in. If you create a `run`
script inside of the `log/` directory of your service directory. It will
automatically pipe the output from the your service into the logging script.

Here we use the `runit` provided `svlogd` daemon to output the serverjs logs
to `$deploy_home/shared/logs/server/`. `svlogd` handles log rotation and
timestamping automatically. No need for `logrotate`.

#### Cleaning up `runit`

    # Waiting for runit to recognize the new service...
    while [ ! -d /etc/service/serverjs/supervise ]; do
      sleep 5 && echo "waiting..."
    done
    sleep 1

    # Turning off the server until the first deploy...
    sv stop serverjs
    > $deploy_home/shared/logs/server/current

It takes `runit` up to 5 seconds to recognize if a folder has been added to
`/etc/service`, so we wait a bit to ensure everything is up and running.

Then, since we don't want `runit` to try to keep the server up until the first
deploy, we shut it down and clear the logs.

Note: you can't run `rm $deploy_home/shared/logs/server/current` because
`svlogd` will not recognize that the log file has been removed, so it won't
create a new one.

#### Giving the `deploy` user access to runit

    # Giving the deploy user the ability to control the service...
    chown -R deploy /etc/service/serverjs/supervise
    chown -R deploy $deploy_home/shared

A neat trick with `runit` is that you don't need to add sudo privileges to
give certain users access to manage services. Instead, all you do is change
the permissions on the `supervise/` directory. Which is what we do here.

#### Using `runit`

`runit` is fairly simple to use, with commands for start, restart, stop and
more. You can find the important ones below:

* `sv restart serverjs` - restarts
* `sv start serverjs` - starts
* `sv stop serverjs` - stops
* `ps -ef | grep runsvdir` - to see runit ps logs

`man sv` for more info.

<h2 id="deploying-code">Deploying code</h2>

Ok! The server's ready. Now onto our local development machine setup.

We use [TJ](https://github.com/visionmedia)'s [deploy shell script](https://github.com/visionmedia/deploy)
to make deploying code repeatable and easy for everyone on the team.

We've already added this script to your github repo. Along with a
`deploy.conf` file that configures it for the instance we just setup.

This lets us deploy to the server by just typing `./deploy nko`.

Here's what the `deploy.conf` looks like:

    [nko]
    key ./id_deploy
    forward-agent yes
    user deploy
    host $ip
    repo git@github.com:nko4/${team}.git
    ref origin/master
    path /home/deploy
    post-deploy npm install && sv restart serverjs
    test sleep 5 && wget -qO /dev/null localhost

`[nko]` is the environment to deploy to. You can have multiple deploy targets,
for instance, `production` and `stage`.

`key ./id_deploy` tells the deploy script to use the ssh key we created for
your team (and that's stored in your repo) to connect to your server to
deploy.

`forward-agent yes` tells the deploy script to enable
[ssh agent forwarding](https://help.github.com/articles/using-ssh-agent-forwarding),
so it can connect to Github from your server.

`user deploy` tells the script to connect as the `deploy` user that we setup
above.

`host $ip` tells the script what ip address to connect to.

`repo git@github.com:nko4/${team}.git` tells the script to deploy code from
your team's github repo.

`ref origin/master` tells the script to deploy the code from master. If you
want, you can deploy a branch with `./deploy nko origin/mybranch`

`path /home/deploy` tells the script where the code should be stored when it
is pulled from github.

`post-deploy npm install && sv restart serverjs` tells the script to install
npm modules and restart the server after the code's been copied from Github.

`test sleep 5 && wget -qO /dev/null localhost` tells the script to roll back
the deploy if the web server isn't responding after 5 seconds.

# Problems?

If you run into any problems, we're here to help. Email <all@nodeknockout.com>
or try us on [Twitter][20] or at IRC, #nodeknockout channel.

[20]: http://twitter.com/node_knockout