load = ->
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

    .on 'click', 'a.change', (e) ->
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

