_This is the 1st in series of posts leading up to the 3rd annual
[Node.js Knockout](http://nodeknockout.com) about how to use
[node.js](http://nodejs.org)._

This post covers how to install node and npm on three popular development
platforms: [Mac](#mac), [Ubuntu](#ubuntu), and [Windows](#windows).

Instructions for other platforms can be found on the
[Node Wiki](https://github.com/joyent/node/wiki/Installation).

<h2 id="easy">The Easy Way</h2>

We personally use package managers to make it easier to keep our node
installation up to date, so that's the approach we generally describe below.

However if you want to skip the steps and download pre-built binaries, you can
do so at Joyent's site: **[download a binary](http://nodejs.org/download/)**.

<h2 id="mac">Mac</h2>

1. [Install Xcode](http://developer.apple.com/xcode/). **Note:** do this
   before the competition, as the Xcode download can take hours.
2. [Install Homebrew](https://github.com/mxcl/homebrew/wiki/installation).
3. At the terminal, type: `brew install node`.

That's it! Check it worked with a simple [Hello, World!](#hello) example.

<h2 id="ubuntu">Ubuntu</h2>

On the latest version of Ubuntu, you can simply:

    sudo apt-get install nodejs nodejs-dev npm

On earlier versions, you might need to update your repository:

    sudo apt-get install python-software-properties
    sudo add-apt-repository ppa:chris-lea/node.js
    sudo apt-get update
    sudo apt-get install nodejs nodejs-dev npm

Then, check it worked with a simple [Hello, World!](#hello) example.

<h2 id="windows">Windows</h2>

Since Windows package managers are less common, we recommend just
[downloading the Windows binary](http://nodejs.org/download/).

<h2 id="hello">Hello, Node.js</h2>

Here's a quick program to make sure everything is up and running correctly.

    // hello_node.js
    var http = require('http');
    http.createServer(function (req, res) {
      res.writeHead(200, {'Content-Type': 'text/plain'});
      res.end('Hello Node.js\n');
    }).listen(8124, "127.0.0.1");
    console.log('Server running at http://127.0.0.1:8124/');

Run the command by typing `node hello_node.js` in your terminal.

Now, if you navigate to [http://127.0.0.1:8124/](http://127.0.0.1:8124/)
in your browser, you should see the message.

## Congrats

You've installed node.js and npm.
