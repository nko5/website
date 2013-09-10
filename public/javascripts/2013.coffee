jQuery ($) ->
  $body = $("body")
  $window = $(window)

  if $("#tumblr-posts").length > 0
    new Tumblr.RecentPosts($("#tumblr-posts")).render()


  $("#header").affix
    offset:
      top: ->
        $('#header .header').outerHeight(true)
      bottom: ->
        $('#header .header').outerHeight(true)

