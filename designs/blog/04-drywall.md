# Going Beyond "Hello World" with Drywall

[Drywall](http://jedireza.github.io/drywall/) is a website and user system for Node.js. It includes a suite of functionality that will save you tons of time with your NKO submission this year. I hope you've been training, this isn't a `hello world` example.

## Take Off the Gloves

Drywall packs a serious punch! __On the server__ we're using Express, Jade, Passport, Mongoose, Async and Emailjs. And __on the client__ we're using Bootstrap, Backbone.js, Underscore.js, jQuery, Font-Awesome and Moment.js.

## Features Include

 - Basic front end web pages.
 - Contact page has form to email.
 - Login system with forgot password and reset password.
 - Signup and Login with Facebook, Twitter and GitHub.
 - Optional email verification during signup flow.
 - User system with seperate account and admin roles.
 - Admin groups with shared permission settings.
 - Administrator level permissions that override group permissions.
 - Global admin quick search component.

## Install Instructions

 1. Clone the repo `$ git clone git@github.com:jedireza/drywall.git && cd drywall`
 2. Run `$ npm install`
 3. Rename `/config.example.js` to `/config.js` and set mongodb and email credentials.
 4. Run app via `$ ./run.js` or `$ node run`

## DB Setup

You need a few records in the database to start using the user system. Run these commands on your mongo database. __Obviously you should use your email address.__

```js
use drywall; //or your db name
db.admingroups.insert({ _id: 'root', name: 'Root' });
db.admins.insert({ name: {first: 'Root', last: 'Admin', full: 'Root Admin'}, groups: ['root'] });
var rootAdmin = db.admins.findOne();
db.users.save({ username: 'root', isActive: 'yes', email: 'your@email.addy', roles: {admin: rootAdmin._id} });
var rootUser = db.users.findOne();
rootAdmin.user = { id: rootUser._id, name: rootUser.username };
db.admins.save(rootAdmin);
```

Now just use the reset password feature to set a password.

 - `http://localhost:3000/login/forgot/`
 - Submit your email address and wait a second.
 - Go check your email and get the reset link.
 - `http://localhost:3000/login/reset/:token/`
 - Set a new password.

Login. Customize. Enjoy.

## Seeing is Believing

| Platform                       | Username | Password |
| ------------------------------ | -------- | -------- |
| https://drywall.nodejitsu.com/ | root     | j1ts00t  |
| https://drywall.herokuapp.com/ | root     | h3r00t   |
| https://drywall.onmodulus.net/ | root     | m0dr00t  |

__Note:__ The live demos have been modified so you cannot change the root user, the root user's linked Administrator role or the root Admin Group. This was done in order to keep the app ready to test at all times.

## Ready for the Next Round!?

 - [Categories & Statuses](https://github.com/jedireza/drywall/wiki/Categories-&-Statuses)
 - [Users, Roles & Groups](https://github.com/jedireza/drywall/wiki/Users,-Roles-&-Groups)
 - [Admin & Admin Group Permissions](https://github.com/jedireza/drywall/wiki/Admin-&-Admin-Group-Permissions)
 - [Going Realtime with Socket.IO](https://github.com/jedireza/drywall/wiki/Going-Realtime-with-Socket.IO)