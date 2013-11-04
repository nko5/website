#!/bin/sh
set -eu

slug=$1
code=$2
name=$3
ip=$4

mkdir -p repos/${slug}
cp ./deploy repos/${slug}/

cd repos/${slug}
git init

cat <<EOF >README.md
## Quick Start

~~~sh
# getting the code
git clone git@github.com:nko4/${slug}.git && cd ./${slug}/

# developing
npm install
npm start

# deploying (to http://${slug}.2013.nodeknockout.com/)
./deploy nko

# ssh access
ssh deploy@${ip}
ssh root@${ip}
~~~

Read more about this setup [on our blog][deploying-nko].

[deploying-nko]: http://blog.nodeknockout.com/#TODO

## Tips

### Your Server

We've already set up a basic node server for you. Details:

* Ubuntu 12.04 (Precise) - 64-bit
* server.js is at: \`/home/deploy/current/server.js\`
* logs are at: \`/home/deploy/shared/logs/server/current\`
* \`runit\` keeps the server running.
  * \`sv restart serverjs\` - restarts
  * \`sv start serverjs\` - starts
  * \`sv stop serverjs\` - stops
  * \`ps -ef | grep runsvdir\` - to see logs
  * \`cat /etc/service/serverjs/run\` - to see the config

You can use the \`./deploy\` script included in this repo to deploy to your
server right now. Advanced users, feel free to tweak.

Read more about this setup [on our blog][deploying-nko].

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
    "nko": "*"
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
}).listen(port, function(err) {
  if (err) { console.error(err); process.exit(-1); }

  // if run as root, downgrade to the owner of this file
  if (process.getuid() === 0) {
    require('fs').stat(__filename, function(err, stats) {
      if (err) { return console.error(err); }
      process.setuid(stats.uid);
    });
  }

  console.log('Server running at http://0.0.0.0:' + port + '/');
});
EOF

cat <<EOF >deploy.conf
# https://github.com/visionmedia/deploy
[nko]
key ./id_deploy
forward-agent yes
user deploy
host $ip
repo git@github.com:nko4/${slug}.git
ref origin/master
path /home/deploy
post-deploy npm install && sv restart serverjs
test sleep 5 && wget -qO /dev/null localhost
EOF

git add .
git commit -m Instructions
git remote add origin git@github.com:nko4/${slug}.git
git push -u origin master
