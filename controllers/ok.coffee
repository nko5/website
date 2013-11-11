util = require 'util'

module.exports = (app) ->
  (req, res, next) ->
    return next() unless req.method is 'GET' and /^\/ok$/.test req.url

    # custom error handler (since the default one dies w/o session)
    error = (err) ->
      util.error err.toString().red
      res.end err.toString()

    try
      req.session.destroy()
    catch err
      return error(err)
    res.send 200
