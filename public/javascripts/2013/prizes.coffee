load = ->

  $(".prizes-widget .images li a").each ->
    $(this).tooltip
      container: "body"

  $(".prizes-widget .icon-users").each ->
    $(this).tooltip
      container: "body"

$(load)
$(document).bind 'end.pjax', load
