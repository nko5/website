jQuery ($) ->
  $body = $("body")
  $window = $(window)

  if $("#tumblr-posts").length > 0
    new Tumblr.RecentPosts($("#tumblr-posts")).render()

  $("#header.affixable").affix
    offset:
      top: ->
        $('#header .header').outerHeight(true) - 60

  $(".subscribe-btn").click (e) ->
    $(".signup-form input[type=email]").focus()
    return true

  $('.edit-team').each ->

    # show the delete box on load if the hash is delete
    if window.location.hash is '#delete'
      window.location.hash = ''
      $form = $('#inner form:first')
      pos = $form.position()
      $delete = $('form.delete').show()
      $delete.css
        left: pos.left + ($form.width() - $delete.outerWidth()) / 2
        top: pos.top

    $('a.remove-btn', this).click ->
      li = $(this).closest('li')
      i = li.prevAll('li').length + 1
      li.html $('<input>',
        class: 'email form-control'
        type: 'email'
        name: 'emails[]'
        placeholder: 'member' + i + '@example.com')
      false