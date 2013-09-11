_This is the 10th in a series of posts leading up to [Node.js
Knockout][1] on debugging node processes using [Node Inspector][2].
This post was written by [Node Knockout judge][3] and [Node Inspector][2]
author Danny Coates._

[1]: http://nodeknockout.com
[2]: https://github.com/dannycoates/node-inspector
[3]: http://nodeknockout.com/people/50854751a9f1fbd123eef7ce

While node has a [built in debugger](http://vimeo.com/19465332), Node
Inspector provides a pleasant graphical interface for debugging node programs.

Node Inspector is a debugger interface for node.js using the WebKit Web
Inspector, the familiar javascript debugger from Safari and Chrome.

## Install

With [npm](http://github.com/isaacs/npm):

    npm install -g node-inspector

## Enable debug mode

To use node-inspector, enable debugging on the node you wish to debug.
You can either start node with a debug flag like:

    $ node --debug your/node/program.js

or, to pause your script on the first line:

    $ node --debug-brk your/short/node/script.js

**NOTE: make sure that the `--debug` flag comes before `your/node/program.js`
or else you may see an `EADDRINUSE` error.**

Or you can enable debugging on a node that is already running by sending
it a signal:

1. Get the PID of the node process using your favorite method. `pgrep`
or `ps -ef` are good

    $ pgrep -l node<br/>
    2345 node your/node/server.js

2. Send it the USR1 signal

    $ kill -s USR1 2345

Great! Now you're ready to attach node-inspector.

## Debugging

1. start the inspector. I usually put it in the background

    $ node-inspector &

2. open [http://127.0.0.1:8080/debug?port=5858][4] in your favorite WebKit
   based browser

3. you should now see the javascript source from node. If you don't,
   click the scripts tab.

4. select a script and set some breakpoints (far left line numbers) or simply
   add a `debugger` call in your code (node will break automatically on the
   call, just as V8 does).

5. then watch the [slightly outdated but hilarious screencasts][5]

`node-inspector` works almost exactly like the web inspector in Safari and
Chrome. Here's a [good overview of the UI][6].

[4]: http://127.0.0.1:8080/debug?port=5858
[5]: http://www.youtube.com/view_play_list?p=A5216AC29A41EFA8
[6]: http://code.google.com/chrome/devtools/docs/scripts.html

## FAQ

1. I don't see one of my script files in the file list.

  > try refreshing the browser (F5 or ⌘-r or control-r)

2. My script runs too fast to attach the debugger.

  > add a `debugger` statement in your code where you want the debugger to
  stop

  > or use `--debug-brk` to pause the script on the first line

3. Can I debug remotely?

  > Yes. node-inspector needs to run on the same machine as the node process,
  but your browser can be anywhere. Just make sure the firewall is open on 8080

4. I got the ui in a weird state.

  > when in doubt, refresh
