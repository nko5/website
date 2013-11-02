# Countdown to NKO 2013 - Deploying Your Node.js App to Ubuntu


<PITCH INTRO TO SAY GOOD ABOUT JOYENT>

This post will get you going with a Node.js example app with NKO module, deployed in a Joyent Ubuntu instance.s


# Do I need to sign up to Joyent?

Short answer: no. Joyent will be providing VPSs during the competition and judging period for teams as a deploy option. More details before the competition.



# The beginning

Every team will have at their disposal a Github repo in which is required to be the development repo for the entire NKO, to start coding on it you can?

```bash
git clone git@github.com:nko4/<teamslug>.git && cd ./<teamslug>/
```

This will get you an example project, to test it you just have to

```bash
npm install
npm start
```

# Linux distro

NKO Ubuntu instances will be running Ubuntu 12.04(Precise) 64-bit version

# Boot and SSH in

The Ubuntu instance will be up and running for you, no setup necessary, in order to get into your machine, you can ssh with

```
ssh deploy@72.2.115.147
ssh root@72.2.115.147
```

### runit 

We're going to use [runit](http://smarden.org/runit/) to make sure your app is running on the server and as soon as you deploy it.

`runit` is fairly simple to use, with commands for start, restart, stop and more, you can find the important ones below:

```
  * `sv restart serverjs` - restarts
  * `sv start serverjs` - starts
  * `sv stop serverjs` - stops
  * `ps -ef | grep runsvdir` - to see logs
  * `cat /etc/service/serverjs/run` - to see the config
```

<h2 id="deploy-script">Deploy script</h2>

Ok! The server's ready. Now onto our local development machine setup.

We've prepared a deploy script you can find in your github repo called `deploy`, to use it you can:

```bash
./deploy
```

# Problems?

If you run into any problems, we're here to help. Email <all@nodeknockout.com>
or try us on [Twitter][20] or at IRC, #nodeknockout channel.

[20]: http://twitter.com/node_knockout