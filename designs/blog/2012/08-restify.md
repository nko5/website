_This is the 8th in a series of posts leading up to [Node.js Knockout][] on
using [restify][].  This post was written by [Node Knockout judge][] and
[restify][] creator Mark Cavage._

[Node.js Knockout]: http://nodeknockout.com
[restify]: http://mcavage.github.com/node-restify
[Node Knockout judge]: http://nodeknockout.com/people/508839a8a56717fe3d000005

[restify](http://mcavage.github.com/node-restify) is a node.js module purpose
built to create REST web services in Node.  restify makes lots of the hard
problems of building such a service, like versioning, error handling and
content-negotiation easier.  It also provides built in
[DTrace](http://dtrace.org/blogs/about/) probes that you get for free to
quickly find out where your application's performance problems lie.  Lastly,
it provides a robust client API that handles
[retry/backoff](http://en.wikipedia.org/wiki/Exponential_backoff) for you on
failed connections, along with some other niceties.

# Installation

Like everything else in node, install restify through [npm](http://npmjs.org/).

    npm install restify

The current stable version stream is `1.4.x`.

# Writing an Application

restify, on the surface, looks very similar to [express](http://expressjs.com/),
which itself looks similar to [sinatra](http://www.sinatrarb.com/), which looks
similar to
[J2EE's Intercepting Filter](http://www.oracle.com/technetwork/java/interceptingfilter-142169.html),
which I'm sure looks similar to something that came before it.  Basically, you
define your app by mapping URLs to a list of functions.  For example, here's
an "echo" server in restify:

    var restify = require('restify');

    var server = restify.createServer();

    server.get('/echo/:name', function (req, res, next) {
      res.send({name: req.params.name});
      next();
    });

    server.listen(8080, function () {
      console.log('%s listening at %s', server.name, server.url);
    });

Fire up that server with `node`:

    $ node echo.js
    restify listening at http://0.0.0.0:8080

And then we can call it with curl (note these examples also assume you've
installed Trent Mick's [jsontool](https://github.com/trentm/json), which is oh
so awesome for working with JSON REST services):

    $ curl -isS localhost:8080/echo/mark | json
    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 15
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Headers: Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version
    Access-Control-Allow-Methods: GET
    Access-Control-Expose-Headers: X-Api-Version, X-Request-Id, X-Response-Time
    Connection: Keep-Alive
    Content-MD5: YWrpZVss8txd0nkH4yISjA==
    Date: Wed, 31 Oct 2012 03:00:37 GMT
    Server: restify
    X-Request-Id: 223ca389-5ee4-4376-89ea-c8a13d0af033
    X-Response-Time: 0

    {
      "name": "mark"
    }

Cool. Note above we had a URL parameter (mark), and we just sent it back.  By
default, restiy assumes JSON services generally (you can override this to
anything, but for NKO you probably want to stick with JSON).

# Writing a "full" restify server

Beyond "hello world", let's take a look at a more "complete" echo server. Note
here I'm also including [bunyan](https://github.com/trentm/node-bunyan) to show
how you can set up both debug logging and audit logging:

    var bunyan = require('bunyan');
    var restify = require('restify');

    var log = bunyan.createLogger({
      name: 'my_restify_application',
      level: process.env.LOG_LEVEL || 'info',
      stream: process.stdout,
      serializers: bunyan.stdSerializers
    });

    var server = restify.createServer({
      log: log,
      name: 'my_restify_application'
    });

    server.use(restify.acceptParser(server.acceptable));
    server.use(restify.authorizationParser());
    server.use(restify.dateParser());
    server.use(restify.queryParser());
    server.use(restify.bodyParser());
    server.use(restify.throttle({
      burst: 100,
      rate: 50,
      ip: true, // throttle based on source ip address
      overrides: {
        '127.0.0.1': {
          rate: 0, // unlimited
          burst: 0
        }
      }
    }));
    server.on('after', restify.auditLogger({ log: log }));

    server.use(function authenticate(req, res, next) {
      // call redis or something here
      next();
    });

    // this one will be explained in the next section
    server.use(function slowPoke(req, res, next) {
      setTimeout(next.bind(this), parseInt((process.env.SLEEP_TIME || 0), 10));
    });

    server.post('/echo/:name', function echoParms(req, res, next) {
      req.log.debug(req.params, 'echoParams: sending back all parameters');
      res.send(req.params);
      next();
    });

    server.listen(8080, function () {
      log.info('%s listening at %s', server.name, server.url);
    });


Let's fire this one up, and set the log level to debug (also, pipe the output to
the bunyan formatter so we get "pretty printed" logs):

    $ npm install bunyan
    $ LOG_LEVEL=debug node echo.js | ./node_modules/.bin/bunyan
    my_restify_application listening at http://0.0.0.0:8080

Now go ahead and invoke curl again (note this time we changed the method to a
POST so we can send some data over):

    $ curl -isS localhost:8080/echo/mark?q1=foo\&q2=bar \
           -X POST -H content-type:application/json \
           --data-binary '{"body_param": "baz"}' | json
    HTTP/1.1 200 OK
    Content-Type: application/json
    Content-Length: 56
    Access-Control-Allow-Origin: *
    Access-Control-Allow-Headers: Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version
    Access-Control-Allow-Methods: POST
    Access-Control-Expose-Headers: X-Api-Version, X-Request-Id, X-Response-Time
    Connection: Keep-Alive
    Content-MD5: J1dujES7TARwUfsRQNMDhw==
    Date: Wed, 31 Oct 2012 03:17:23 GMT
    Server: my_restify_application
    X-Request-Id: 3a8404f5-c5be-45d0-a4be-38f17c9e60d1
    X-Response-Time: 1

    {
        "name": "mark",
        "q1": "foo",
        "q2": "bar",
        "body_param": "baz"
    }

This time, we should also have seen the following information kick back from the
server console:

    [2012-10-31T03:17:23.853Z] DEBUG: mark/51296 on bluesnoop: echoParams: sending back all parameters (req_id=3a8404f5-c5be-45d0-a4be-38f17c9e60d1, route="POST /echo/:name", q1=foo, q2=bar, body_param=baz)
    [2012-10-31T03:17:23.856Z]  INFO: my_restify_application/51296 on bluesnoop: POST /echo/:name handled: 200 (req_id=3a8404f5-c5be-45d0-a4be-38f17c9e60d1, 4ms, audit=true, remoteAddress=127.0.0.1, remotePort=50996, secure=false, _audit=true, req.version=*)
        POST /echo/mark?q1=foo&q2=bar HTTP/1.1
        user-agent: curl/7.21.4 (universal-apple-darwin11.0) libcurl/7.21.4 OpenSSL/0.9.8r zlib/1.2.5
        host: localhost:8080
        accept: */*
        content-type: application/json
        content-length: 21
        --
        HTTP/1.1 200 OK
        content-type: application/json
        content-length: 56
        access-control-allow-origin: *
        access-control-allow-headers: Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version
        access-control-allow-methods: POST
        access-control-expose-headers: X-Api-Version, X-Request-Id, X-Response-Time
        connection: Keep-Alive
        content-md5: J1dujES7TARwUfsRQNMDhw==
        date: Wed, 31 Oct 2012 03:17:23 GMT
        server: my_restify_application
        x-request-id: 3a8404f5-c5be-45d0-a4be-38f17c9e60d1
        x-response-time: 4
        --
        route: {
          "name": "POST /echo/:name",
          "version": false
        }

Note that if we didn't pipe the output to the bunyan formatter, we would have
had logs in pure JSON, making it easier to mine later.

# DTracing a restify application

Note: this section is only applicable if you are on
[Mac OS X](http://www.apple.com/osx/) or [Joyent SmartOS](http://smartos.org/).
You'll want 3 shell sessions open for this.

Ok, so above I added a `slowPoke` handler:

    server.use(function slowPoke(req, res, next) {
      setTimeout(next.bind(this), parseInt((process.env.SLEEP_TIME || 0), 10));
    });

Which notably lets us pass in an arbitrary amount of time to pause. Let's one
more time fire up the server but with a lag in it (also, let's skip the bunyan
formatter so you see what I mean about JSON logs):

    $ SLEEP_TIME=500 node echo.js
    {"name":"my_restify_application","hostname":"bluesnoop","pid":51387,"level":30,"msg":"my_restify_application listening at http://0.0.0.0:8080","time":"2012-10-31T03:29:01.627Z","v":0}

Great. Now in another terminal, start running loop of our curl commands (put it
in `()` so you can ctrl-c sanely):

    $ (while [ true ] ; do curl -isS localhost:8080/echo/mark?q1=foo\&q2=bar -X POST -H content-type:application/json --data-binary '{"body_param": "baz"}' ; done)

You should see it going pretty slowly, seeing as we have a sleep in there.  Now,
lets go find that sleep from DTrace.  In a third window run this:

    $ sudo dtrace -lP my_restify_application*
    ID   PROVIDER            MODULE                          FUNCTION NAME
    6168 my_restify_application52121            module                              func postechoname-start
    6169 my_restify_application52121            module                              func postechoname-done
    6170 my_restify_application52121            module                              func postechoname-parseAccept-start
    6171 my_restify_application52121            module                              func postechoname-parseAccept-done
    6172 my_restify_application52121            module                              func postechoname-parseAuthorization-start
    6173 my_restify_application52121            module                              func postechoname-parseAuthorization-done
    6174 my_restify_application52121            module                              func postechoname-parseDate-start
    6175 my_restify_application52121            module                              func postechoname-parseDate-done
    6176 my_restify_application52121            module                              func postechoname-parseQueryString-start
    6177 my_restify_application52121            module                              func postechoname-parseQueryString-done
    6178 my_restify_application52121            module                              func postechoname-parseBody-start
    6179 my_restify_application52121            module                              func postechoname-parseBody-done
    6180 my_restify_application52121            module                              func postechoname-rateLimit-start
    6181 my_restify_application52121            module                              func postechoname-rateLimit-done
    6182 my_restify_application52121            module                              func postechoname-authenticate-start
    6183 my_restify_application52121            module                              func postechoname-authenticate-done
    6184 my_restify_application52121            module                              func postechoname-slowPoke-start
    6185 my_restify_application52121            module                              func postechoname-slowPoke-done
    6186 my_restify_application52121            module                              func postechoname-echoParms-start
    6187 my_restify_application52121            module                              func postechoname-echoParms-done

Note those are all of our handlers. Nice, huh?  Now, without going into the
details of DTrace, here's a nice D script you can run that will show you latency
broken down by handler:

    #!/usr/sbin/dtrace -s
    #pragma D option quiet

    my_restify_application*:::postechoname-*-start
    {
            tracker[arg0, substr(probename, 0, rindex(probename, "-"))] = timestamp;
    }

    my_restify_application*:::postechoname-*-done
    /tracker[arg0, substr(probename, 0, rindex(probename, "-"))]/
    {
            this->name = substr(probename, 0, rindex(probename, "-"));
            @[this->name] = quantize(((timestamp - tracker[arg0, this->name]) / 1000000));
            tracker[arg0, substr(probename, 0, rindex(probename, "-"))] = 0;
    }

Go ahead and run that for a few seconds (let's say 5-10):

    $ chmod +x ./echo.d
    $ sudo ./echo.d
    ^C

    postechoname-authenticate
    value  ------------- Distribution ------------- count
    -1 |                                         0
    0 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 9
    1 |                                         0

    postechoname-parseAccept
    value  ------------- Distribution ------------- count
    -1 |                                         0
    0 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 9
    1 |                                         0

    postechoname-parseAuthorization
    value  ------------- Distribution ------------- count
    -1 |                                         0
    0 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 9
    1 |                                         0

    postechoname-parseBody
    value  ------------- Distribution ------------- count
    -1 |                                         0
    0 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 9
    1 |                                         0

    postechoname-parseDate
    value  ------------- Distribution ------------- count
    -1 |                                         0
    0 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 9
    1 |                                         0

    postechoname-parseQueryString
    value  ------------- Distribution ------------- count
    -1 |                                         0
    0 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 9
    1 |                                         0

    postechoname-rateLimit
    value  ------------- Distribution ------------- count
    -1 |                                         0
    0 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 9
    1 |                                         0

    postechoname-echoParms
    value  ------------- Distribution ------------- count
    -1 |                                         0
    0 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 10
    1 |                                         0

    postechoname-slowPoke
    value  ------------- Distribution ------------- count
    128 |                                         0
    256 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ 9
    512 |                                         0

And we see that our latency is sorted according to "worst"; at the bottom
is our `slowPoke` handler, chewing up time while everything else is running
< ms.  With this it's pretty obvious what you should go look at.

# Wrap up

Obviouly real applications have a lot more moving parts than what was shown
here, but hopefully you have a grasp on the basics of restify are.  I've left
out the details on lots of complex parts of it; like any dependency you'll have
to read the [docs](http://mcavage.github.com/node-restify) a bit more thoroughly
to get into more advanced uses.  But if you're looking to build a well-behaved
REST application, this should help get you going.
