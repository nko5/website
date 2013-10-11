// Usage: mongo nko4_development scripts/team-limits.js
var limits = {
  '2013-09-17T00:00:00Z': 10,
  '2013-09-18T00:00:00Z': 100,
  '2013-09-18T12:00:00Z': 200,
  '2013-10-11T00:00:00Z': 250,
  '2013-10-11T12:00:00Z': 300
};

for(dateString in limits) {
  var limit = limits[dateString];

  var date = new Date(Date.parse(dateString));
  print("Setting team limit to " + limit + " at " + date);

  db.teamlimits.update({ effectiveAt: date }, { $set: { limit: limit }}, true);
}
