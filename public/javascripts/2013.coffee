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

pad = (num, size) ->
  s = "000000000" + num
  s.substr s.length - size

load = ->
  $('.autofocus :text:first').focus() # focus first input

  $(".with-tooltip").each ->
    $(this).tooltip
      container: "body"

  $(".with-popover").each ->
    $(this).popover
      content: $(this).find(".popover-content").html()
      html: true
      placement: $(this).data("placement") || "top"
      trigger: "hover"
      container: "body"

  $(".confirm-form").submit (e) ->
    return confirm($(this).data('confirm-msg') || "Are you sure?")

  $("textarea.autosized").autosize()

  $(".countdown .timer").each ->
    el = $(this)
    end = moment.utc($(this).data("from")).toDate()

    update = ->
      ts = countdown(moment.utc().toDate(), end)
      el.html """
        <span class="time-section"><strong>#{pad(ts.days,2)}</strong>D</span>
        <span class="time-section"><strong>#{pad(ts.hours,2)}</strong>H</span>
        <span class="time-section"><strong>#{pad(ts.minutes,2)}</strong>M</span>
        <span class="time-section"><strong>#{pad(ts.seconds,2)}</strong>S</span>
      """
    update()
    el.closest(".countdown").show()
    setInterval update, 1000

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
