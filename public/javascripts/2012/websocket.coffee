load = ->
  ws = nko.ws

  # reload the page after ~10 seconds (if you're on the index page)
  ws.on 'reload', ->
    setTimeout ->
      if window.location.pathname is '/'
        window.location.reload()
    , (Math.random() * 10000)

  ws.on 'updateStats', (stats) ->
    updateStats $("#overall-stats"), stats

  # update the stats billboard on the team page
  ws.on 'updateTeamStats', (json) ->
    { teamId, stats } = json
    updateStats $(".team-stats[data-team-id=#{teamId}]"), stats

  # update the deployed stuff
  ws.on 'deploy', (team) ->
    updateEntryInfo($('#recent-deploys'), team)

  # update the interesting entrys on judge visit
  ws.on 'judgeVisit', (team) ->
    updateEntryInfo($('#interesting-teams'), team)

  updateStats = ($el, stats) ->
    for k, v of stats
      $el.find(".#{k} .number").text(v)

  updateEntryInfo = ($el, team) ->
    $toAdd = template 'entry-info', team: team

    $toRemove = $el.find(".entry-info[data-team-id=#{team.id}]:first")
    if $toRemove.length is 0
      $toRemove = $el.find('.entry-info:last')

    $toRemove.remove()
    $toAdd.hide().prependTo($el).animate width: 'show'

$(load)
# note no pjax load here
