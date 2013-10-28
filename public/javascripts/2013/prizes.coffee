load = ->
  $(".prizes-widget .with-popover").each ->
    $(this).popover
      content: $(this).find(".popover-content").html()
      html: true
      placement: $(this).data("placement") || "top"
      trigger: "hover"
      container: "body"

  $(".prizes-widget .images li a").each ->
    $(this).tooltip
      container: "body"

  $(".prizes-widget .icon-users").each ->
    $(this).tooltip
      container: "body"

$(load)
$(document).bind 'end.pjax', load
