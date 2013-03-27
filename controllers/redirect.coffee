util = require 'util'
app = require '../config/app'

app.get /\/(.*)/, (req, res, next) ->
  path = req.params[0]
  if /^(stylesheets|javascripts|images|fonts)/.test(path)
    next() # don't redirect for stylesheets and the like
  else
    # let 2012 routes redirect for a while
    util.log('redirecting to http://2012.nodeknockout.com' + req.url)
    res.redirect('http://2012.nodeknockout.com' + req.url, 301)

###
app.get /^/, (req, res, next) ->
  next 404
###
