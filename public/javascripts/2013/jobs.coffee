load = ->
  $(".jobs-list").each ->
    $(this).find("a[href='#more']").click (e) ->
      e.preventDefault()
      $(this).hide().parent().next(".more:first").slideDown()

$(load)
$(document).bind 'end.pjax', load
