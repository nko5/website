_This is the 4th in a series of posts leading up to [Node.js
Knockout][1] on how to use [Socket.IO][2]. This post was written by
socket.io creator [Guillermo Rauch][3]._

[1]: http://nodeknockout.com
[2]: http://socket.io/
[3]: http://www.devthought.com/

# Knocking out Socket.IO

Ready to rock the Node Knockout 3?  Considering making a
real-time app or game? Then you're likely considering
[Socket.IO](http://socket.io).

## Socket.IO makes realtime easy and cross-browser

If the web 2.0 was about AJAX requests and responses, the real-time web
is about **events**.

With Socket.IO, you can emit events from the server to the client and
vice-versa, at any time.

Consider the following example, in which we *push* data from the server
to the client every 3 seconds. We're going to get the latest tweets and
render them on the client.

On the server side, we create a directory called `example/` with the
following `package.json` inside:

    {
        "name": "example"
      , "version": "0.0.2"
      , "dependencies": {
            "socket.io": "~0.9.10"
          , "request": "~2.11.4"
        }
    }

Then run `npm install`. That will get Socket.IO and a library to make
http requests (to Twitter) very simple to write.

Create an `app.js` with the following:

    var sio = require('socket.io')
      , http = require('http')
      , index = require('fs').readFileSync(__dirname + '/index.html')
      , request = require('request')

    var app = http.createServer(function (req, res) {
          res.writeHead(200, { 'Content-Type': 'text/html' });
          res.end(index);
        })
      , io = sio.listen(app);

    app.listen(3000);

So far, we initialized a HTTP server that serves the index file,
and we attach Socket.IO to it. We then make it listen on port 3000.

We're now gonna search twitter every 2 seconds to send tweets to the client.
The clients don't explicitly request it like in traditional Ajax, but we _push_
it to them:

    setInterval(function () {
      request({
        url: 'http://search.twitter.com/search.json?q=today'
      }, function (err, res, data) {
        var obj = JSON.parse(data);
        io.sockets.emit('tweets', obj.results.map(function (v) { return v.text; }));
      });
    }, 2000);

Notice that I accessed the `io.sockets` property. That's what we call the
`Manager` of sockets, which also emits a `connection` event for individual
people that connect:

    io.sockets.on('connection', function (socket) {
      socket.broadcast.emit('someone connected');

      socket.on('some event', function () {
        console.log('I got an event');
      });
    });

In this case, I'm making this socket `broadcast` to others that it connected.
Broadcasting from the `socket` object means in this case we're sending a message to
everyone else, except for that particular socket.

Now that we're done with the server part, we capture these events on the client
and do some jQuery juggling. Create an `index.html` with this code:

    <!doctype html>
    <html>
      <head>
        <script src="/socket.io/socket.io.js"></script>
        <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js"></script>

        <script>
          var socket = io.connect();

          $(function () {
            socket.on('tweets', function (tweets) {
              $.each(tweets, function (i, tweet) {
                $('#tweets').prepend($('<li>').text(tweet));
              });
            });

            socket.on('someone connected', function () {
              $('body').prepend('<p>Someone just connected!</p>');
            });

            socket.emit('some event');
          });
        </script>
      </head>
      <body>
        <h1>Tweets</h1>
        <ul id="tweets"></ul>
      </body>
    </html>

## Putting sockets in rooms

Many times you need to emit information to certain people and not others.
Use `socket.join`:

    io.sockets.on('connection', function (socket) {
      socket.join('fighters');
    });

Then you can broadcast and emit to those people:

    // to all sockets in a group
    io.sockets.in('fighters').emit('something');

    // from a socket to the rest of the sockets
    socket.broadcast.to('fighters').emit('something else');

## Tools for game makers.

Remember the `broadcast` property that I accessed above? That's what we call a
`flag`:

A useful one for game developers is called the `volatile` flag. If you ever
have data that it's not absolutely crucial that the client gets if the client
has not finished receiving previous messages, you can make that volatile:

    socket.volatile.emit('position', x, y);

If the player changes its `x` and `y` coordinates really quickly, and we're not
done sending a particular position, some packets will be dropped. This will
make things faster in many scenarios.

## Going beyond, with callbacks

On both ends (server and client side), you can pass a function to request a
explicit data response. Consider an example where the chat client sets a
nickname, but you want to validate whether it's available or not.

On the client:

    socket.emit('set nickname', $('#my-input').val(), function (available) {
      if (available) {
        alert('Nick is available. Congrats!');
      } else {
        alert('Nick not available');
      }
    });

On the server:

    io.sockets.on('connection', function (socket) {
      socket.on('set nickname', function (fn) {
        isNickNameAvailable(function (bool) {
          fn(bool);
        });
      });
    });

## Wrapping up

You can check out [the example on GitHub][4]. Clone the repo, then run
`npm install` and `node app` and point your browser to
`http://localhost:3000`!

These are all the tools in your toolbox. Go make great realtime apps!

[4]: https://github.com/nko3/knocking-out-socket.io
