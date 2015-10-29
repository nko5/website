load = ->

  $(".prizes-widget .nav-tabs li a").click (e) ->
    slug = $(this).attr("href")
    slug = slug.replace("#", "") if slug

    stateObj = { slug: slug };
    history.replaceState(stateObj, slug, "/prizes##{slug}");

  if $("body").is(".index-prizes")
    initialState = window.location.hash
    if initialState and initialState != "#"
      $(".prizes-widget .nav-tabs li a[href='#{initialState}']").click()

  $(".prizes-widget .images li a").each ->
    $(this).tooltip
      container: "body"

  $(".prizes-widget .icon-users").each ->
    $(this).tooltip
      container: "body"

$(load)
$(document).bind 'end.pjax', load
