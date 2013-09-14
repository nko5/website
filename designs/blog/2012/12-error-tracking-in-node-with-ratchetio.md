_This is the 12th in a series of posts leading up to [Node.js
Knockout][1], and covers using [Ratchet.io][2] in your node app._

[1]: http://nodeknockout.com
[2]: https://ratchet.io

Ratchet.io is an error monitoring, aggregation and intelligence service that
has plugins for a wide variety of languages and frameworks including Rails, 
Django, PHP and Node.js.

Let's create a simple server with some bugs to get started.


## Installation

    npm install ratchetio
    npm install express


## Middleware

Most servers written in node use the Express.js framework which is built on top 
of Connect.js and makes it really easy to write and include custom middleware. 
Let's include Ratchet's error handling middleware and record our first error.

    var express = require('express'),
        ratchet = require('ratchetio');

    var app = express();

    app.use(app.router);

    // Make sure this is below the app.router
    app.use(ratchet.errorHandler('ACCESS_TOKEN'));

    app.get('/', function(req, res) {
          throw new Error('Hello World!');
    });

    console.log('browse to http://localhost:8080/ and then to your ' +
        'ratchet.io project');
    app.listen(8080);

### Create a Ratchet.io project

If you haven't created a project on Ratchet.io yet, head over to 
[https://ratchet.io/fasttrack/nk2012/](https://ratchet.io/fasttrack/nk2012/) 
and create a free account. Then, replace the `ACCESS_TOKEN` in the code above 
with your server-side access token.

![Screenshot of post-signup page][ss1]


Next, you should be able to run your server and see the following in your 
browser at [http://localhost:8080](http://localhost:8080):

![Screenshot of node error page][ss2]

And now on ratchet.io:

![Screenshot of Ratchet.io dashboard][ss3]


## Recording things other than errors

Recording errors is great but sometimes we just want to do the equivalent of 
`console.log()` and have it stored in one place even when running on multiple 
production servers.

Ratchet makes this dead simple. Just pass in the string to send over along with 
an optional level (or it will default to `error`). Choices for level include `debug`, `info`, `warning`, `error` and `critical`.

    ratchet.reportMessage('Why the heck is this not working??? ' + (typeof myVar), 'debug');

And if you want to send over some useful request context...

    ratchet.reportMessage('Oooooh, is it because the cookie is missing?', 
        'debug', request);

![Screenshot of instance page showing message and cookies][ss4]


## Tracking disaster with `UncaughtException`

Node.js has a super-handy and potentially dangerous event that it will trigger 
when there's an uncaught exception at the top-most level of your code. These 
are the types of things that will kill your server so it's good to know when 
and why they happened.

Thankfully, node.js makes it super-simple to track these and so does Ratchet.

    ratchet.handleUncaughtExceptions();


### UncaughtException example

    var ratchet = require('ratchetio');
    ratchet.handleUncaughtExceptions('ACCESS_TOKEN');

    var foo = bar();

![Screenshot of ratchet.io instance][ss5]


## More control

It's important to have full control over when error reporting happens. Ratchet 
provides a few different options for when to report errors and messages back 
to ratchet.io. 

### setInterval

This is the default handler if one is not specified. It will create a `Timer` 
function which will execute every `N` seconds, (where `N` is configurable using the `handlerInterval` option.)

e.g. Queue up any errors/messages and send to ratchet.io every 10 seconds

    ratchet.init("ACCESS_TOKEN", {handler: "setInterval", handlerInterval: 10});
    
or
    
    app.use(ratchet.errorHandler("ACCESS_TOKEN", 
        {handler: "setInterval", handlerInterval: 10});

### nextTick

This handler will schedule a callback which will send any queued up 
errors/messages to ratchet.io on the next tick of the javascript runtime. This 
is useful for ensuring that any callbacks passed into the `handleError` or 
`reportMessage` functions is called asynchronously.

    ratchet.init("ACCESS_TOKEN", {handler: "nextTick"});
    ratchet.reportMessage("Record me asynchronously", "debug", function(ratchetErr) {
        if (err) {
            console.log("Problem sending message to ratchet: " + ratchetErr);
        } else {
            console.log("Recorded message to ratchet");
        }
    });

### inline

This handler will send any recorded messages or errors to ratchet as soon as 
they are processed. This is useful for debugging complex code and making sure 
that important errors are sent to ratchet.io as soon as possible.

    ratchet.init("ACCESS_TOKEN", {handler: "inline"});
    ratchet.reportMessage("DATABASE IS DOWN!", "critical", function(ratchetErr) {
        if (err) {
            console.log("Problem sending message to ratchet: " + ratchetErr);
        } else {
            console.log("Recorded message to ratchet... shutting down");
            ratchet.shutdown();
            process.exit(1);
        }
    });

### Changing handler types

The Ratchet notifier also allows you to switch handler types whenever you want. 
If you notice that the queue is building up or you need to start pushing errors 
to ratchet.io as soon as they're available, it's as simple as:

    ratchet.changeHandler("inline");

or 

    ratchet.changeHandler("setInterval");


## Everything is asynchronous...

Under the covers, the Ratchet node notifier is completely asynchronous and 
provides the ability to pass around callbacks that are executed after any i/o 
occurs. 

e.g. Trigger a callback to make sure a message was queued to be sent to ratchet.io:

    ratchet.reportMessage("Something important", "info", function(ratchetErr) {
        // ratchetErr will be null if the message was queued
    });

e.g. Execute some code after ratchet is cleanly shutdown:

    ratchet.shutdown(function(ratchetErr) {
        // this function will be called after all queued items were sent 
        // to ratchet.io or an error occurred
    });


## Next Steps

That's really all there is to it. The above instructions should cover 95% of 
the average use cases.

Happy Hacking!

### For the remaining 5%

We're continually adding new features to ratchet.io and all of the notifiers. 
If you're interested, take a look at the [api.js][apijs] code for some more 
functionality or at our [API docs][apidocs] for even more.

Send us an email at [support@ratchet.io](mailto:support@ratchet.io) or a 
pull request for bugfixes and/or new features!

[ss1]: //d2tf6sbdgil6xr.cloudfront.net/static/img/blog/nk2012-1.png
[ss2]: //d2tf6sbdgil6xr.cloudfront.net/static/img/blog/nk2012-2.png
[ss3]: //d2tf6sbdgil6xr.cloudfront.net/static/img/blog/nk2012-3.png
[ss4]: //d2tf6sbdgil6xr.cloudfront.net/static/img/blog/nk2012-4.png
[ss5]: //d2tf6sbdgil6xr.cloudfront.net/static/img/blog/nk2012-5.png
[apijs]: https://github.com/ratchetio/node_ratchet/blob/master/lib/api.js
[apidocs]: https://ratchet.io/docs/api_items
