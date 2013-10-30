request = require 'request'
env = require './env'

module.exports = github = (args...) -> github.get(args...)

github.url = (path) ->
  auth = "#{env.secrets.github_setup_token}:x-oauth-basic"
  "https://#{auth}@api.github.com/#{path}"

github.request = (method, path, json, next) ->
  unless next?
    next = json
    json = {}
  url = github.url(path)
  # console.log "github: #{method} #{url}"
  request
    method: method
    url: url
    json: json
  , next

['get', 'put', 'post', 'del'].forEach (method) ->
  github[method] = (args...) -> github.request(method, args...)
