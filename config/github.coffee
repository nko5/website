request = require 'request'

module.exports = ({ username, password }) ->
  throw 'username required' unless username
  throw 'password required' unless password

  github = (args...) -> github.get(args...)

  github.url = (path) ->
    auth = "#{username}:#{encodeURIComponent(password)}"
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

  ['get', 'put', 'post'].forEach (method) ->
    github[method] = (args...) -> github.request(method, args...)

  github
