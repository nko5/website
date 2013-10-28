#!/bin/sh
set -eu

slug=$1
code=$2
name=$3

mkdir -p repos/${slug}
cp ./deploy repos/${slug}/

cd repos/${slug}
git init

cat <<EOF >README.md
## Quick Start

~~~sh
# getting the code
git clone git@github.com:nko4/${slug}.git && cd ./${slug}/

# deploying the code
./deploy

# ssh access to your server
ssh deploy@${slug}.2013.nodeknockout.com
ssh root@${slug}.2013.nodeknockout.com
~~~

## Tips

### Your Server

We've already set up a basic node server for you. Details:

* Ubuntu 12.10 (Precise) - 64-bit
* server.js is at: \`/home/deploy/current/server.js\`
* logs are at: \`/home/deploy/shared/logs/server.log\`
* \`runit\` keeps the server running.
  * \`sv restart serverjs\` - restarts
  * \`sv start serverjs\` - starts
  * \`sv stop serverjs\` - stops
  * \`runsvdir -P /etc/service log\` - to see logs
  * \`cat /etc/service/serverjs/run\` - to see the config

You can use the \`./deploy\` script included in this repo to deploy to your
server right now. Advanced users, feel free to tweak.

[Find out more](http://blog.nodeknockout.com/deploying-to-joyent)

### Vote KO Widget

![Vote KO widget](http://f.cl.ly/items/1n3g0W0F0G3V0i0d0321/Screen%20Shot%202012-11-04%20at%2010.01.36%20AM.png)

Use our "Vote KO" widget to let from your app directly. Here's the code for
including it in your site:

~~~html
<iframe src="http://nodeknockout.com/iframe/${slug}" frameborder=0 scrolling=no allowtransparency=true width=115 height=25>
</iframe>
~~~

### Tutorials & Free Services

If you're feeling a bit lost about how to get started or what to use, we've
got some [great resources for you](http://nodeknockout.com/resources).

First, we've pulled together a great set of tutorials about some of node's
best and most useful libraries:

* [How to install node and npm](http://blog.nodeknockout.com/post/33857791331/how-to-install-node-npm)
* [Getting started with Express](http://blog.nodeknockout.com/post/34180474119/getting-started-with-express)
* [Real-time communication with Socket.IO](http://blog.nodeknockout.com/post/34243127010/knocking-out-socket-io)
* [Data persistence with Mongoose](http://blog.nodeknockout.com/post/34302423628/getting-started-with-mongoose)
* [OAuth integration using Passport](http://blog.nodeknockout.com/post/34765538605/getting-started-with-passport)
* [Debugging with Node Inspector](http://blog.nodeknockout.com/post/34843655876/debugging-with-node-inspector)
* [and many more](http://nodeknockout.com/resources#tutorials)&hellip;

Also, we've got a bunch of great free services provided by sponsors,
including:

* [MongoLab](http://nodeknockout.com/resources#mongolab) - for Mongo hosting
* [Monitaur](http://nodeknockout.com/resources#monitaur) - for server monitoring
* [Ratchet.io](http://nodeknockout.com/resources#ratchetio) - for exception tracking
* [Teleportd](http://nodeknockout.com/resources#teleportd) - real-time photo streams
* [and more](http://nodeknockout.com/resources#tutorials)&hellip;

## Have fun!

If you have any issues, we're on IRC in #nodeknockout on freenode, email us at
<all@nodeknockout.com>, or tweet [@node_knockout](https://twitter.com/node_knockout).
EOF

cat <<EOF >package.json
{
  "name": "nko4-${slug}",
  "version": "0.0.0",
  "description": "${name}",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "repository": {
    "type": "git",
    "url": "git@github.com:nko4/${slug}.git"
  },
  "dependencies": {
    "nko": "*",
  },
  "engines": {
    "node": "0.10.x"
  }
}
EOF

cat <<EOF >server.js
// https://github.com/nko4/website/blob/master/module/README.md#nodejs-knockout-deploy-check-ins
require('nko')('${code}');

var isProduction = (process.env.NODE_ENV === 'production');
var http = require('http');
var port = (isProduction ? 80 : 8000);

http.createServer(function (req, res) {
  // http://blog.nodeknockout.com/post/35364532732/protip-add-the-vote-ko-badge-to-your-app
  var voteko = '<iframe src="http://nodeknockout.com/iframe/${slug}" frameborder=0 scrolling=no allowtransparency=true width=115 height=25></iframe>';

  res.writeHead(200, {'Content-Type': 'text/html'});
  res.end('<html><body>' + voteko + '</body></html>\n');
}).listen(port);

console.log('Server running at http://0.0.0.0:' + port + '/');
EOF

cat <<EOF >deploy.conf
# https://github.com/visionmedia/deploy
[production]
user deploy
host ${slug}.2013.nodeknockout.com
repo git@github.com:nko4/${slug}.git
ref origin/master
path /home/deploy
post-deploy npm install && sudo sv restart serverjs
test sleep 5 && wget -qO /dev/null localhost
EOF

git add .
git commit -m Instructions
git remote add origin git@github.com:nko4/${slug}.git
git push origin master
