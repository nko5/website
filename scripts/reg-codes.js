// Usage: mongo nko5_development scripts/reg-codes.js
var codes = {
  'JSWEEKLY': 25,
};

for(codeString in codes) {
  var limit = codes[codeString];

  print("Setting reg code " + codeString + ": " + limit);

  db.regcodes.update({ code: codeString.toLowerCase() }, { $set: { limit: limit }}, true);
}
