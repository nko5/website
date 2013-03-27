require('coffee-script');

[ // 'login',
  'index',
  // 'iframe',
  // 'people',
  // 'judges',
  // 'teams',
  // 'votes',
  // 'websocket',
  // 'live',
  'redirect',
  // 'notifications'
].forEach(function(controller) {
  require('./controllers/' + controller);
});

// commits and deploys are required directly in app.js
