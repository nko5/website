# How to Hackathon

_This post was written by
[Chicago Node.js](http://www.meetup.com/Chicago-Nodejs/) organizer and
[Groupon Engineer](https://engineering.groupon.com)
[Sean Massa](http://massalabs.com/)
([@endangeredmassa](https://twitter.com/endangeredmassa))._

Below are my points of advice for anyone participating in Node Knockout.
This information comes from mistakes I made
in past Node Knockout competitions!

Note that many of these suggestions will apply to new or in-progress projects
regardless of hackathons.

## Preparation

**Know the Rules**:
These things have rules
and it's very important to know what they are.
Read [the rules](http://nodeknockout.com/rules) in full.
You should also read the emails you receive
with instructions about
using the Node Knockout repositories
and [nodejitsu](https://www.nodejitsu.com/) deployment system.

**Develop Your Idea**:
We're getting down to the wire!
You should pick your idea as soon as possible
and spend time thinking about.
You can't create any digital assets ahead of time,
but you should definitely
come up with a plan of attack.
This can include learning libraries or tools ahead of time.

**Know What You Want to Get Out of This**:
Before Node Knockout even starts,
you should know what you hope to get out of it.
It could be to win the entire hackathon,
win a specific category,
to build something just so that it exists,
or to have fun.
Decide what this is ahead of time
and prioritize you efforts towards that goal.


## Execution

**Use a Project Template**:
You don't want to waste time at the start of the event setting up your dev environment.
Find a project template that you like, or create your own, and use it!
Here are a few starting points:
[coffeescript-project](https://github.com/michaelficarra/coffeescript-project),
[expressjs](http://expressjs.com/guide.html#executable),
[html5boilerplate](http://html5boilerplate.com).

**Deploy First, Then Often**:
Nodejitsu is providing hosting services for Node Knockout.
They will have several people in
[#nodejitsu on irc.freenode.net](http://webchat.jit.su),
ready to help you!
However, you shouldn't wait until the end of Node Knockout
to make sure your deploys work.
Sometime shortly after you get your project set up,
add a quick response mechanism (like a route for a web server),
deploy it to nodejitsu,
and make sure it can respond properly.
If anything goes wrong, hop into that IRC room
and provide as much information as possible about your issue!

**Git Like Crazy**:
You must use git for Node Knockout.
So, make sure you know how to use it.
That means being gamiliar with commits, branches, merge/rebase, and revert.

**Don’t Ignore Architecture**:
You are never going too fast to skip spending time
thinking about the architecture of your features.
The short-term focus of hackathons will often lead to many bugs.
If you ignore architecture, these issues will be amplified.

**Prioritize All Work**:
For everything that you do,
ask yourself if it is the best thing you can do right now
to complete your project's minimum viable product (MVP).
Your MVP can shift throughout the event,
but each feature you start should be compared against it.

**Use Existing Libraries**:
There are times where you will want to rewrite some functionality
because it will be easier "your way".
For hackathons, I urge you to work through
whatever trouble you have with the existing solutions
and focus on what you should be building.

**Don’t Necessarily Ignore TDD**:
If you normally practice test-driven development (TDD),
don't assume that it has no place in hackathons.
Just like normal projects,
you should decide where it makes sense
for you to TDD and where it doesn't.
The difference here is that the line is in a different place.
It's hard to provide any hard rules here,
but you should be mindful of the situation.
Make sure your template project has you
set up to write tests if you choose to.

**Don’t Ignore Meatspace**:
In hackathons, some people consider skipping meals and sleep,
sometimes with the help of caffeine.
I am definitely guilty of this in the past.
However, it never seems to provide much benefit.
You may accomplish some work overnight,
but people who do this are often much less capable
to help with problems that will arise at the very end of the event.
You will know your own body better than me,
but you should consider planning for
some amount of sleep during the event.

**Schedule Distractions**:
Remove real-time distractions (IM, email, etc.)
that can interrupt you during work.
You should also take real breaks away from your work
to allow your subconscious to continue working on the problem
while you take care of some physical need.

**Pair Appropriately**:
Pair programming is incredibly helpful in general.
Try to pair often during hackathons.
The bug count is already going to be higher than normal.
Use that second pair of eyes to help keep it down
and keep you focused.

**Support Multiple Users**:
If your app requires multiple users to showcase its core concepts,
it can be hard for people to judge it.
If you can build even a naive AI or small seed data set,
the judges will be able to experience your app properly.
You can also schedule times where judges can use your app
with the developers (and possibly other users).

**Leave Time for Testing**:
The last couple of hours before the end of a hackathon are always hectic.
Schedule at least two hours leading up to the end
in order to test, debug, and polish your app.
Really, it should be more than two.


## App Design

**Avoid New Accounts**:
If you are making an app that requires user accounts in some way,
either also allow guest accounts or
allow social media account connections.
People are lazy.
If they have to sign up for an account to look at your app,
they might just skip it.
Judges are obligated too dig in,
but peers and the populace are not.

**Ignore Security**:
Unless it's a selling point of your app,
don't worry about security concerns.
They will likely cost you time without providing demo-able benefit.
You can add those features in after the hackathon
if you choose to continue your project.


## Reflection

**Record a Demo**:
Node Knockout allows you to record a video demo of your app.
Do it.
Do it immediately after the end of the competition.
Make sure that the video shows the best case scenario,
skips trivial things like account creation,
and is quick, but informative.

**Talk About It**:
Recalling this experience will help you
learn from and internalize it.
You should do this however you feel comfortable.
That can be blogging,
discussing the event at a meetup or the IRC room,
or just quietly thinking about the experience to yourself.


## Core Advice

The `tl;dr` of it all, inconveniently at the end, is this:

* take care of your body
* always have a goal
* always prioritize work toward that goal

This post was based on a presentation I gave at
[Chicago Node.js](http://www.meetup.com/Chicago-Nodejs).
You can find the original slides
[here](https://docs.google.com/presentation/d/1s5OHHfzlmzhXp7hthjjHD7fREj2xavI3MZ6c9Q9D0aE/edit?usp=sharing).
