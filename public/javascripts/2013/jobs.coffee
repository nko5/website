switchJobDisplay = (slug) ->
  return unless slug
  slug = slug.replace("#", "")

  jobsList = $(".jobs-list")
  jobsList.find(".job").hide()
  jobsList.find(".job-icon").removeClass("active")
  jobsList.find(".job-icon[data-job='#{slug}']").addClass("active")
  jobsList.find(".job[data-job='#{slug}']").show()

  stateObj = { slug: slug };
  history.replaceState(stateObj, slug, "/jobs##{slug}");

load = ->
  $(".jobs-list").each ->
    $(this).find("a[href='#more']").click (e) ->
      e.preventDefault()
      $(this).hide().parent().next(".more:first").slideDown()

    $(this).find(".job-icon").mouseover (e) ->
      switchJobDisplay($(this).data("job"))
    $(this).find(".job-icon").click (e) ->
      switchJobDisplay($(this).data("job"))

  if $("body").is(".index-jobs")
    initialState = window.location.hash
    if initialState and initialState != "#"
      switchJobDisplay(initialState)

$(load)
$(document).bind 'end.pjax', load
