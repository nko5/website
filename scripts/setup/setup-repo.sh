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
git clone git@github.com:nko5/${slug}.git && cd ./${slug}/

# developing
npm install
npm start

# deploying (to http://${slug}.2015.nodeknockout.com/)
./deploy nko

# ssh access
ssh deploy@${slug}.2015.nodeknockout.com
ssh root@${slug}.2015.nodeknockout.com
# or, if you get prompted for a password
ssh -i ./id_deploy deploy@${slug}.2015.nodeknockout.com
ssh -i ./id_deploy root@${slug}.2015.nodeknockout.com
~~~

Read more about this setup [on our blog][deploying-nko].

[deploying-nko]: http://blog.nodeknockout.com/post/66039926165/node-knockout-deployment-setup

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
got some [great resources for you](http://nodeknockout.com/resources),
including:

* [How to install node and npm](http://blog.nodeknockout.com/post/65463770933/how-to-install-node-js-and-npm)
* [Getting started with Express](http://blog.nodeknockout.com/post/65630558855/getting-started-with-express)
* [OAuth with Passport](http://blog.nodeknockout.com/post/66118192565/getting-started-with-passport)
* [Going Beyond “Hello World” with Drywall](http://blog.nodeknockout.com/post/65711111886/going-beyond-hello-world-with-drywall)
* [and many more](http://nodeknockout.com/resources#tutorials)&hellip;

## Have fun!

If you have any issues, we're on IRC in #nodeknockout on freenode, email us at
<help@nodeknockout.com>, or tweet [@nodeknockout](https://twitter.com/nodeknockout).
EOF

cat <<EOF >package.json
{
  "name": "nko5-${slug}",
  "version": "0.0.0",
  "description": "${name}",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "repository": {
    "type": "git",
    "url": "git@github.com:nko5/${slug}.git"
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
// https://github.com/nko5/website/blob/master/module/README.md#nodejs-knockout-deploy-check-ins
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
host ${slug}.2015.nodeknockout.com
repo git@github.com:nko5/${slug}.git
ref origin/master
path /home/deploy
post-deploy npm install && sv restart serverjs
test sleep 5 && wget -qO /dev/null localhost
EOF

git add .
git commit -m Initial
git remote add origin git@github.com:nko5/${slug}.git

cat <<'EOF' >gitssh.sh
#!/bin/sh
exec /usr/bin/ssh -i ./id_deploy "$@"
EOF
chmod +x gitssh.sh

GIT_SSH=./gitssh.sh git push -u origin master

rm gitssh.sh
