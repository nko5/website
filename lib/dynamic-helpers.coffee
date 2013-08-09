module.exports = (dynamicHelpers) ->
  self = this
  for name, fn of dynamicHelpers
    do (name, fn) ->
      self.use (req, res, next) ->
        res.locals[name] = fn(req, res)
        next()