$('#page.judges').each ->
  $('a.delete').click (e) ->
    if confirm('Are you sure?')
      $a = $(this)
      $.ajax $a.attr('href'),
        type: 'DELETE'
        success: ->
          $a.closest('li').slideUp()
    false
