_This is the 11th in a series of posts leading up to [Node.js
Knockout][1] on debugging node processes using [Bonsai.js][2].
This post was written by [Bonsai.js][2] contributor [Dustan Kasten][3] of
[Skookum Digital Works](http://skookum.com/)._

[1]: http://nodeknockout.com
[2]: http://bonsaijs.org/
[3]: https://github.com/iamdustan

# Telling Stories with Bonsai.js

Bonsai.js is a new graphics library that, unlike most graphic libraries
currently in the wild, ships with an SVG renderer. Not only that, but it has
an architecturally separate runner and renderer so that all the heavy
lifting can happen in an iFrame, WebWorker, or node context.

Built by the amazing team at [Uxebu](http://www.uxebu.com), Bonsai is
the HTML5 library that [Pixelplant](http://www.pixelplant.com) depends
on for its Flash conversion. If you are familiar with Flash
development or terminology you already have a grasp of how to create
with bonsai.

> Note: All of this code is available at [https://github.com/iamdustan/bonsai-demos](https://github.com/iamdustan/bonsai-demos). To view demos, `git clone git@github.com:iamdustan/bonsai-demos && npm start` then browse to `http://localhost:8080` in your favorite browser.

## From Tree Level

A few things to note as you walk into the bonsai forest. Due to the
architecturally separated runner and renderer, all of the code that
draws to the bonsai stage is run in a sandbox. In this sandbox you have
access to a large number of tools that bonsai creates for you (many
examples listed below under **Bonsai Tools**).

The bonsai world revolves around the
[stage](http://docs.bonsaijs.org/Stage.html). The runner and renderer
communicate through passing messages back and forth. This is for both
user triggered actions (e.g. pointer events and clicks) or for things
you want to trigger (say, pressing a Start button).

## Bonsai Tools

These are just a few of the objects bonsai makes available to you in the
runner context.

**[Simple shapes](http://docs.bonsaijs.org/overview/SimpleShapes.html)**

* Rect
* Arc
* Circle
* Ellipse
* Polgyon
* Star

**[Assets](http://docs.bonsaijs.org/overview/Assets.html)**

* Audio
* Bitmap
* FontFamily
* Movie
* Video

**And more...**

* [Animation](http://docs.bonsaijs.org/module-animation.Animation.html)
* [KeyfameAnimation](http://docs.bonsaijs.org/module-animation.KeyframeAnimation.html)
* [Matrix](http://docs.bonsaijs.org/Matrix.html)
* [LinearGradient](http://docs.bonsaijs.org/module-gradient.LinearGradient.html)

## Let The Fun Begin

Getting started with bonsai always seems to be the biggest hurdle. The
documentation has recently been super-sized with an explanation of the
execution environment that is required reading: [Bonsai
execution](http://docs.bonsaijs.org/overview/Execution.html).

Through the following examples, you will have everything you need to
know to get started making awesome.

### Grab the Latest Bonsai

Releases happen very regularly with new features added and bugs
smashed. The latest official release is always available on
[github](https://github.com/uxebu/bonsai/downloads) or from the
[cdn](http://cdnjs.cloudflare.com/ajax/libs/bonsai/0.4.1/bonsai.min.js).
Additionally, if you are like me and feeling a bit edgier you could
just build the latest copy from master yourself (requires java to run
Closure Compiler):

    cd /tmp; git clone git@github.com:Uxebu/bonsai && make build
    cp ./dist/bonsai.js YOUR_DIRECTORY_HERE

### A Simple Example

To start things off we&rsquo;re going to do the smallest amount of
boilerplate necessary and demonstrate a few of the methods and sugar
that Bonsai provides.

    // pass a function through as the code parameter

    var element = document.getElementById('movie');
    bonsai.run(movie, {
      code: runner,
      width: 600,
      height: 400
    });

    function runner () {
      var rect = new Rect(0, 0, 200, 200);
      rect
        .fill('random')
        .addTo(stage)
        .attr({
          x: stage.width - rect.attr('width'),
          y: stage.width - rect.attr('height')
        })
        .animate('0.5s', {
          x: 0,
          y: 0
        });
    }

As you can see, our instance of a Rect has some helpful methods
accompanying it, and don&rsquo;t forget the lovely color, `random`.
All displayable objects are an instance of a
[DisplayObject](http://docs.bonsaijs.org/DisplayObject.html), aptly
title. 

Clearly, this method will not scale to complex code, so let&rsquo;s
break that off.

### Separating Things Out

Let&rsquo;s begin by moving that runner method into a file to call its
own, following the Flash semantics, `movie.js`.

    // movie.js
    var rect = new Rect(0, 0, 200, 200);
    rect
      .fill('random')
      .addTo(stage)
      .attr({
        x: stage.width - rect.attr('width'),
        y: stage.width - rect.attr('height')
      })
      .animate('0.5s', {
        x: 0,
        y: 0
      });


    // app.js
    var element = document.getElementById('movie');
    bonsai.run(movie, {
      url: 'path/to/movie.js',
      plugins: [],
      width: 600,
      height: 400
    });

Well, that was easy enough. Bonsai here is taking the file you specify
under the `url` key and loading into the appropriate runner context.

### Don&rsquo;t Forget to Listen to Your Users

Let&rsquo;s continue adding complexity and add a second file to handle
user interactions. Bonsai pipes all user interaction into the runner
context. This is imperative since the runner has no concept of things
like pointer events or `event.pageX`

    // ui.js
    stage.on('message', handleMessage)
    stage.on('pointerdown', handlePointerdown)
    stage.on('keypress', handleKeypress)

    function handleMessage(message) {
      if (message.type === 'Rect' && message.attr)
        new Rect(message.attr.x, message.attr.y, message.attr.w, message.attr.h)
          .attr(message.attr)
          .fill(message.attr.fill || 'random')
          .addTo(stage);
    }

    function handlePointerdown (e) {
      handleMessage({
        type: 'Rect',
        attr: {
          x: e.stageX-25,
          y: e.stageY-25,
          w: 50,
          h: 50
        }
      })
    }

    function handleKeypress (e) {
      stage.sendMessage('keypress', e.keyCode);
    }


    // app.js
    var element = document.getElementById('movie');
    var stage = bonsai.run(movie, {
      url: 'path/to/movie.js',
      plugins: ['path/to/ui.js'],
      width: 600,
      height: 400
    });

    stage.sendMessage({
      type: 'Rect',
      attr: {
        x: Math.random() * 100, y: Math.random() * 100,
        w: Math.random() * 100, h: Math.random() * 100
      }
    });

    stage.on('message:keypress', function (data) {
      console.log('Hey! Someone touched me at {keyCode}! - the
    Keyboard'.replace(/{keyCode}/g, data));
    });

### But This Is Node Knockout

Oh right. I almost forgot. We&rsquo;ve just been letting bonsai manage
setting up the runner context in a WebWorker or iFrame so far. We need a
way to run this on the server and connect our thousand friends to it.
Very well, let&rsquo;s get to it!

Up to this point we&rsquo;ve been starting bonsai and passing the
configuration object all at the same time. We will use a slightly
different version this time where we first call setup passing in a
Socket.io runner context.

> Note: This demo uses a currently custom build of Bonsai that exposes a few internal utilities. Grab it here: https://github.com/uxebu/bonsai-server/blob/master/example/bonsai.js

    // main.js

    var movie = document.getElementById('movie')
    var runnerContext = function (runnerUrl) {
      this.socket = io.connect(runnerUrl);
    };

    // some boilerplate to connext via socket.io
    var proto = runnerContext.prototype = bonsai.tools.mixin({
      init: function () {
        var self = this;
        this.socket.on('message', function(msg) {
          self.emit('message', msg[0]);
        });
      },
      notify: function (message) {
        this.socket.emit('message', message);
      },
      notifyRunner: function (message) {
        this.socket.emit('message', message);
      },
      run: function (code) {
        this.notifyRunner({
          command: 'runScript',
          code: code
        });
      }
    }, bonsai.EventEmitter);

    proto.notifyRunnerAsync = proto.notifyRunner;

    bonsai
      .setup({
        runnerContext: runnerContext,
        runnerUrl: 'http://localhost:3000
      })
      .run(movie, {
        width: 600,
        height: 600
      });


    // movie.js
    // this is read by and run on the server
    // demo from http://demos.bonsaijs.org/demos/circles/index.html
    var centerX = 250,
        centerY = 250,
        circles = 180,
        distance = 180,
        frames = 14,
        radiusMin = 10,
        radiusVar = 10;

    var circle, random = Math.random;

    for (var i = 0; i < circles; ++i) {
        var f = i / circles,
            x = centerX + distance * Math.sin(f*2*Math.PI),
            y = centerY + distance * -Math.cos(f*2*Math.PI),
            radius = random() * radiusVar + radiusMin;

        circle = new Circle(x, y, radius).
          attr({fillColor: 'random', fillGradient: bonsai.gradient.radial(['#FFFFFF88', '#FFFFFF00'])});

        circle.x = x;
        circle.y = y;

        stage.addChild(circle);
    }

    var c = stage.children();
    stage.length(frames);
    var spread = 80;
    stage.on(0, function() {
      for (var i = 0, circle; (circle = c[i++]); ) {
        circle.animate(frames, {
          x: circle.x + spread * random() - spread / 2,
          y: circle.y + spread * random() - spread / 2
        }, {easing: 'sineInOut'});
      }
    });


    // server.js
    var bonsai = require('bonsai');
    var fs = require('fs');

    var bonsaiCode = fs.readFileSync('./movie.js');
    var socketRenderer = function (socket) {
      this.socket = socket;
    };

    var socket = require('socket.io').listen(4000);

    socket.sockets.on('connection', function (socket) {
      var movie = bonsai.run(null, {
        code: bonsaiCode,
        plugins: []
      });

      movie.runnerContext.on('message', function () {
        socket.emit('message', arguments);
      });

      movie.on('message', function (msg) {
        movie.runnerContext.notifyRunner(msg);
      });

      socket.on('disconnect', function () {
        movie.destroy();
      });

    });


    // package.json
    {
      name: "roger-rabbit",
      version: "0.0.0",
      main: "server.js",
      dependencies: {
        "bonsai": "git+ssh://git@github.com:uxebu/bonsai.git",
        "socket.io": "~0.9.10"
      }
    }


Here we are using the node modules socket.io and bonsai, which
we&rsquo;re grabbing straight from the source. **(Note: `npm install bonsai`
will return a different module.)** Socket.io is responsible for keeping the
connection live and then just being the telephone wire transfering
messages from the runner to the renderers.

## Additional Resources

Bonsai is a young, but active project and community. Learn more, get
involved, and stay connected.

* IRC on freednode at #bonsaijs
* [Online editor and examples](http://orbit.bonsaijs.com)
* [Documentation](http://docs.bonsaijs.com)
* More examples:
https://github.com/uxebu/bonsai/tree/master/example/library (git clone
and open the index.html located here)

I look forward to seeing what you create with Bonsai!
