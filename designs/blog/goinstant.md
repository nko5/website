# Using GoInstant to Create Multiplayer Real-time Node Apps

## Overview
GoInstant handles the realtime and data storage layers for web and mobile apps, so you don't have to. We have simple APIs for pub/sub messaging, data synchronization, data storage, multi-user management, authentication, and connection management. It's low latency, secure, and scales for you. We have customizable widgets for UI features like User Lists and Notifications and MVC integrations like GoAngular that synchronize your model across users and devices. Our goal is to make it as easy as powerful to build awesome realtime, multi-user apps.

Last year several of the Node Knockout winning teams combined Node.js with a multi-user experience to create amazing apps like Disasteroids, Hex, Narwhal Knights & Space Bridge.  We hope more teams will do the same this year, but with GoInstant you’ll be able to build the multi-user aspects of your apps even faster!

### You can sign up for a free account and see live examples at goinstant.com.

Every winner at Node Knockout is going to get a free lifetime Developer account of GoInstant. We’ll be giving out some hoodies too. As well, we’re offering an extra prize to the best app using GoInstant. It’s a free “One of Everything” Tessel (for awesome hardware hacking using JavaScript!) For details on that, you can read the announcement here: http://bit.ly/H4J5qH.

## Why Node + GoInstant?
We love Node.js at GoInstant, but when you're talking about building multi-user & collaborative applications rapidly - it's not out-of-the-box friendly!  This is where GoInstant comes into play.  By combining Node.js with GoInstant you don't have to worry about data storage, synchronization or a number of other issues that inevitably creep up when building collaborative apps.  We handle it all for you!

## Creating a multi-user snake game
To show you how easy it is to create a multi-user experience for any app, we created a simple snake game using GoInstant. The objective in Snake is pretty simple--you control a snake on the screen and try to eat as much food as possible without hitting into the walls. Every time you eat food, your snakes grows in length. Here’s what GoSnake looks like:


![img1](https://github.com/nko4/website/blob/master/designs/blog/img/img1.png)


### So let’s build GoSnake together! 
(Note: All of this code is available on GitHub: https://github.com/piwh1000/GoSnake)

To get started: 

* The first step is to render an HTML5 canvas, and randomly draw snakes and food on the map on a 60ms game loop. The game loop detects the collision between the snake and the food and redraws the snakes based on direction. At this stage only the blue snake can be controlled by the end user and there is no AI.

![img2](https://github.com/nko4/website/blob/master/designs/blog/img/img2.png)

* Now we want to add multi-user capabilities. To get started with GoInstant, include the minified source files and run the GoInstant connect helper function to establish the connection to GoInstant.

![img3](https://github.com/nko4/website/blob/master/designs/blog/img/img3.png)

```javascript
<script type="text/javascript" src="https://cdn.goinstant.net/v1/platform.min.js"></script>

<script>
var url = 'https://goinstant.net/YOURACCOUNT/YOURAPP';
var connection = new goinstant.Connection(url);
connection.connect(function(err) {
  if (err) {
    console.log('Error connecting to GoInstant:', err);
    return;
  }
});
</script>
```

* Once connected to GoInstant, we can use a few GoInstant Widgets that add multi-user features out-of-the-box:
  * The User List widget shows you who else is in the game
  * The User Colors widget gives each snake a unique color
  * The Notifications widgets shows you when someone joins the game

With just a few lines of code, anyone can see who joins the room with notifications and the user list.

* At this stage the widgets have added a bit of functionality, mostly around user presence.  Now, we want to start sharing information between all users in the game. To sync data between users, we use Keys.  Keys are in reference to a key-value store. The Key object provides the interface for managing and monitoring a value in our server-side data store.  Keys can handle up to 32 KB of booleans, arrays, numbers, objects or strings.

For Snakes, the data we want to share is the position of the food and the position/direction of all of the snakes. When the game is initialized we call a function initializeFood. This creates the food object and then creates and listens on the food key. When the values are updated on GoInstant,  the listener will change the value to match it, so all users see the food in the exact same coordinates.

```javascript
function initializeFood(cb) {
  food = {
    key: lobby.key('/food'),
    color: 'black',
    position: {
      x: 0,
      y: 0
    }
  };
  var foodListener = function(val) {
    food.position = val;
  };

  food.key.on('set', { local: true, listener: foodListener });
  food.key.get(function(err, value, context) {
    if (value) {
      food.position = value;
      return cb();
    }
    spawnFood(cb);
  });
}

function spawnFood(cb) {
  food.position.x = Math.round(Math.random()*(canvas.width-BLOCK_SIZE)/BLOCK_SIZE);
  food.position.y = Math.round(Math.random()*(canvas.height-BLOCK_SIZE)/BLOCK_SIZE);
  food.key.set(food.position, function(err) {
    if(err) {
      throw err;
    }
    if (cb)
    return cb();
  });
}
```

![img4](https://github.com/nko4/website/blob/master/designs/blog/img/img4.png)

* The next step is handling users joining the Room. New users joining the game will be issued a snake in a random location and will inherit a color based on the User Colors widget.

For simplicity’s sake, we redraw the snake based on its coordinates and direction in each game loop. When a user updates the direction by hitting the arrow keys on the computer, it syncs to all other users in the room.  Each user is in control of re-spawning their own snake if they hit the wall. All of the users' snakes are stored as keys. 

```javascript
  function initializeSnake(cb) {
  snakes[myUserId] = {
    blocks: [],
    currentScore: INITIAL_SCORE,
    length: INITIAL_SNAKE_LENGTH,
    direction: ''
  };
  el.userScore.text(INITIAL_SCORE);

  // randomly select a color for the user
  var userColors = new goinstant.widgets.UserColors({ room: lobby });
  userColors.choose(function(err, color) {
    if (err) {
      throw err;
    }

    $('.user-label').css('background-color',color);

    // set that as their snake color
    snakes[myUserId].color = color;

    for(var x = 0; x < snakes[myUserId].length; x++) {
      snakes[myUserId].blocks[x] = { x: 0, y: 0 };
    }
    var snakeListener = function(val, context) {
      var username = context.key.substr('/snakes/'.length);
      snakes[username] = context.value;
    };
    snakeKey.on('set', { bubble:true, listener: snakeListener });
    snakeKey.key("/" + myUserId).set(snakes[myUserId], function(err) {
      if (err) {
        throw err;
      }
      snakeKey.get(function(err, value, context) {
        if (err) {
          throw err;
        }
        snakes = value;
        spawnSnake(myUserId);
        return cb();
      });
    });
  });
}
```

![img5](https://github.com/nko4/website/blob/master/designs/blog/img/img5.png)

* Success! We now have a fully functioning multi-snake game.  Until now, everything has been in a room called ‘lobby’ which is the default room in every GoInstant application. If we stuck with the lobby, anyone who came to the URL would join any existing game. For our example, we want some level of control so people can invite specific friends and not just play with random strangers.

The last thing we want to add in is the ability to share an individual game with your friends. For this, we go back to the concept of Rooms.  Rooms are instances of your application within GoInstant. Each room holds a number of users and Keys. A user must be in a room to interact with other users, or manipulate keys. A user can be in more than one room at a time, using a single connection. 

```javascript
  function initializeSharing(cb) {
  // We are interested in knowing if there is a new query on the URL when the
  // slide show is loaded. This detects the use of the query parameter in the
  // default slide deck to change the transitions and themes.
  var parser = document.createElement('a');
  parser.href = window.location.toString();

  // Create the sharing URL by adding the roomName as a query parameter to
  // the current window.location.
  if (parser.search) {
    parser.search += '&' + GO_SNAKE_ID + '=' + roomName;
  } else {
    parser.search = '?' + GO_SNAKE_ID + '=' + roomName;
  }

  // Create Share Button
  addShareButton(parser.href);
}

function addShareButton(text) {
  var shareBtn = document.createElement('div');
  var cssBtn = 'display: block; position: fixed; bottom: 1em; left: 0; ' +
    'z-index: 9999; height: 17px; padding: 9px; font-size: 15px; ' +
    'font-family: sans-serif; font-weight: bold; background: white; ' +
    'border-radius: 0 3px 3px 0; border: 1px solid #ccc; ' +
    'text-decoration: none; color: #15A815;';
  var cssURL = 'font-weight: regular;';

  shareBtn.innerHTML = 'Share';
  shareBtn.style.cssText = cssBtn;

  var main = document.getElementsByClassName('instructions')[0];
  main.parentNode.insertBefore(shareBtn, main);

  shareBtn.onmouseover = function() {
    if (this.poppedOut) {
      return;
    }
    this.poppedOut = true;

    this.innerHTML +=
      '<input id="gi-share-text" type="text" value="' + text +
      '" style="margin: -5px 0 0 15px; padding: 5px; width: 180px;"/>';

    this.style.width = '250px';
    document.getElementById('gi-share-text').select();
  };

  shareBtn.onmouseout = function(evt) {
    if (evt.relatedTarget && evt.relatedTarget.id === 'gi-share-text') {
      return;
    }
    this.poppedOut = false;

    this.innerHTML = 'Share';
    this.style.width = 'auto';
  };
}

function setRoomName() {
  // if we have the go-SNAKE room in sessionStorage then just connect to
  // the room and continue with the initialization.
  roomName = sessionStorage.getItem(GO_SNAKE_ID);
  if (roomName) {
    return true;
  }

  // if we do not have the name in storage then check to see if the window
  // location contains a query string containing the id of the room.

  // creating an anchor tag and assigning the href to the window location
  // will automatically parse out the URL components ... sweet.
  var parser = document.createElement('a');
  parser.href = window.location.toString();

  var hasRoom = QUERY_REGEX.exec(parser.search);
  var roomId = hasRoom && hasRoom[2];
  if (roomId) {
    roomName = roomId.toString();
    // add the cookie to the document.
    sessionStorage.setItem(GO_SNAKE_ID, roomName);

    // regenerate the URI without the go-SNAKE query parameter and reload
    // the page with the new URI.
    var beforeRoom = hasRoom[1];
    if (beforeRoom[beforeRoom.length - 1] === '&') {
      beforeRoom = beforeRoom.slice(0, beforeRoom.lengh - 1);
    }
    var searchStr = beforeRoom + hasRoom[3];
    if (searchStr.length > 0) {
      searchStr = '?' + searchStr;
    }

    parser.search = searchStr;

    // set the new location and discontinue the initialization.
    window.location = parser.href;
    return false;
  }

  // there is no room to join for this SNAKE so simply create a new
  // room and set the cookie in case of future refreshes.
  var id = Math.floor(Math.random() * Math.pow(2, 32));
  roomName = id.toString();
  sessionStorage.setItem(GO_SNAKE_ID, roomName);

  return true;
}
```

Finally we add the variable roomName to the GoInstant connection and users now have control over who accesses the game.

```javascript
goinstant.connect(GO_SNAKE_APP_URL, { room: roomName }, function(err, platform, room) });
```

* For final touches we beautified the design and added in scores.  The best part about GoInstant isn't just the fact you can add a multi-user experience quickly, but that you can customize it and retrofit it to your app. 

The userlist widget by default just floats to the right and over top of the content.  It doesn't provide an optimal experience in it's current format.  To pretty it up all we need to do is change the container with a bit of javascript when we create the userlist widget and add the container in our CSS theme.  Pretty simple!
```javascript
    var userListElement = $('.user-list-container')[0];

  var userList = new goinstant.widgets.UserList({
    room: lobby,
    collapsed: false,
    position: 'right',
    container: userListElement
  });
```

### To see the game in action check it out (be sure to share it since it can be a lot of fun with more players): http://piwh1000.github.io/GoSnake/

To fork the source code:
https://github.com/piwh1000/GoSnake

### Hopefully you see the power of GoInstant and how easy it is to create a beautiful multi-user experience for your Node Knockout application.
To get a better understanding of GoInstant check out our documentation at https://developers.goinstant.com/beta/ and signup at https://goinstant.com/signup.

