jQuery ($) ->
  $body = $("body")
  $window = $(window)

  if $("#tumblr-posts").length > 0
    new Tumblr.RecentPosts($("#tumblr-posts")).render()

  $("#header.affixable").affix
    offset:
      top: ->
        $('#header .header').outerHeight(true) - 60

  $(".subscribe-btn").click (e) ->
    $(".signup-form input[type=email]").focus()
    return true