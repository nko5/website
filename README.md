                     _         _       _                     _               _
     _ __   ___   __| | ___   (_)___  | | ___ __   ___   ___| | _____  _   _| |_
    | '_ \ / _ \ / _` |/ _ \  | / __| | |/ / '_ \ / _ \ / __| |/ / _ \| | | | __|
    | | | | (_) | (_| |  __/_ | \__ \ |   <| | | | (_) | (__|   < (_) | |_| | |_
    |_| |_|\___/ \__,_|\___(_)/ |___/ |_|\_\_| |_|\___/ \___|_|\_\___/ \__,_|\__|
                            |__/

[node.js knockout] is a 48-hour programming contest featuring [node.js]. it
owes its roots to [rails rumble]. holla.

[node.js knockout]:http://nodeknockout.com/
[node.js]:http://nodejs.org/
[rails rumble]:http://railsrumble.com/


dependencies:

    brew install mongodb redis

to install

    npm install

to start server:

    npm start

to start console:

    node

to deploy
    
    NODE_ENV=production ./node_modules/.bin/coffee scripts/package-assets.coffee
    modulus deploy


