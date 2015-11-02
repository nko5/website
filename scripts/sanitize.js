// Usage: mongo nko5_development scripts/sanitize.js
db.people.find({ email: { $nin: [
      /^visnupx?@gmail.com$/,
      'gerads@gmail.com',
      'jcnetdev@gmail.com',
      'sakinac@gmail.com',
      /@fortnightlabs\.com$/,
      /\.nodeknockout.com$/] }}).forEach(function(doc) {

  // ensure no emails
  if (doc.email) {
    db.people.update({ _id: doc._id }, {
      $set: { email: doc.email + '.nodeknockout.com' }});
  }

  // ensure no DMs
  if (doc.twitterScreenName) {
    db.people.update({ _id: doc._id }, {
      $unset: { twitterScreenName: 1 }});
  }
});
