$ = jQuery

# ensure csrf token is included in all ajax requests
# from https://github.com/rails/jquery-ujs/blob/master/src/rails.js
$.ajaxPrefilter (options, originalOptions, xhr) ->
  token = $('meta[name="_csrf"]').attr('content')
  xhr.setRequestHeader 'X-CSRF-Token', token

$ ->
  $body = $("body")
  $window = $(window)

  if $("#tumblr-posts").length > 0
    new Tumblr.RecentPosts($("#tumblr-posts")).render()

  # $("#header.affixable").affix
  #   offset:
  #     top: ->
  #       $('#header .header').outerHeight(true) - 60

  $(".subscribe-btn").click (e) ->
    $(".signup-form input[type=email]").focus()
    return true

# speed up default jQuery animations
$.fx.speeds._default = 200

# notify team when judges click through
$(document).on 'mousedown', 'a[href^=http]', (e) ->
  $.post "/notify", { url: this.href }

load = ->
  $(':text:first').focus() # focus first input

  $(".with-popover").each ->
    $(this).popover
      content: $(this).find(".popover-content").html()
      html: true
      placement: $(this).data("placement") || "top"
      trigger: "hover"
      container: "body"

  # team and people delete confirm
  $('#page.teams-edit, #page.people-edit').each ->
    $('a.remove', this).click ->
      $this = $(this)
      pos = $this.position()
      form = $('form.delete')
      form
        .fadeIn('fast')
        .css
          left: pos.left + ($this.width() - form.outerWidth())/2
          top: pos.top + ($this.height() - form.outerHeight())/2
      false

    $('form.delete a', this).click ->
      $(this).closest('form').fadeOut('fast')
      false

$(load)
$(document).bind 'end.pjax', load
