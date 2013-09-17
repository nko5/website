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

  # voting form
  requestAt = Date.now()
  hoverAt = null
  $('form.vote')
    .hover (e) ->
      hoverAt or= Date.now()
    .submit (e) ->
      $this = $(this)
        .find('input[type=hidden].hoverAt').val(hoverAt).end()
        .find('input[type=hidden].requestAt').val(requestAt).end()

      # require at least one star
      $stars = $this.find('div.stars')
      if $stars.length != $stars.filter(':has(.star.filled)').length
        alert 'All ratings must have at least 1 star.'
        e.stopImmediatePropagation()
        return false

      # prompt if no comment
      $note = $this.find('textarea')
      if $note.length > 0 and not $note.val()
        unless confirm "Are you sure you want to vote without leaving any feedback?"
          e.stopImmediatePropagation()
          return false

      true
    .on 'a.change', 'click', (e) ->
      e.preventDefault()
      $form = $(this).closest('form').toggleClass('view edit')
      $form[0].reset()
      $('input, textarea', $form)
        .change() # reset stars
        .prop('disabled', $form.is('.view'))
    .find('input[type=range]').stars()

  # replies
  $('a.toggle-reply-form').click (e) ->
    $('a.toggle-reply-form').toggle();
    f = $('form.reply', $(this).closest('.vote')).slideToggle ->
      $('textarea:first', this).focus()
    f[0].reset()
    false

$(load)
$(document).bind 'end.pjax', load
