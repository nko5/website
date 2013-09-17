# ensure csrf token is included in all ajax requests
# from https://github.com/rails/jquery-ujs/blob/master/src/rails.js
jQuery.ajaxPrefilter (options, originalOptions, xhr) ->
  token = $('meta[name="_csrf"]').attr('content')
  xhr.setRequestHeader 'X-CSRF-Token', token

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
