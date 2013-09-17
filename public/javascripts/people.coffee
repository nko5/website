$(document).on('change','form.person .role select', ->
  $this = $ this
  $this.next('.technical').toggle($this.val() is 'judge')
).change()

$(document).on('blur','form.person .email input',  ->
  $this = $ this
  return unless val = $this.val()

  $img = $this.closest('form').find('.image_url')
  return if $img.find('input').val()

  email = $.trim(val.toLowerCase())
  $img.find('img.avatar').attr('src', "http://gravatar.com/avatar/#{md5(email)}?s=80&d=retro")
).change()

$(document).on('blur', 'form.person .twitter input', ->
  $this = $ this
  $form = $this.closest('form')
  return $this.next('.spinner').hide() unless $this.val()

  $this.next('.spinner').show()
  
  $.getJSON '/twitter/' + encodeURI($.trim($this.val())),
    # username: ,
    (data) ->
      $form.find('.name :text').val (i, v) -> v or data.name
      $form.find('.location :text').val (i, v) -> v or data.location
      $form.find('.bio textarea').text (i, t) -> t or data.description

      unless $form.find('.image_url input').val()
        image_url = data.profile_image_url.replace '_normal.', '.'
        $form.find('.image_url')
          .find('img.avatar').attr('src', image_url).end()
          .find('input').val image_url

      $this.next('.spinner').hide()
).blur()


load = ->
  $('#page.people-show .next-vote form.vote a.skip').click (e) ->
    e.preventDefault()
    $('#page.people-show .next-vote .skip-vote').submit()

  # editing votes on your page does an ajax submit
  $('#page.people-show .votes form.vote').submit (e) ->
    $form = $(this)
    $inputs = $form.find('input, textarea')
    $.ajax
      type: $form.attr 'method'
      url: $form.attr 'action'
      data: $form.serializeArray()
      beforeSend: ->
        $inputs.prop('disabled', true)
      success: (data) ->
        if $inputs.filter('[name=_method]').val() is 'DELETE'
          $form.remove()
        else
          # update the defaults
          $inputs.each ->
            this.defaultValue = $(this).val()
          $form.find('a.change:first').click()
      error: (xhr) ->
        # TODO this is lame
        alert 'Error editing vote. Please try again'
        $inputs.prop 'disabled', false
    e.preventDefault()

  $('form.person .image_url').each ->
    $i = $(this)

    # setup the transloadit form
    # TODO may not need the iframe BS
    $t = $i.find('.transloadit')
    $iframe = $t.find('iframe').contents()
    $form = $iframe.find('body').html($t.find('script').html()).find('form')
    $file = $form.find('input[type=file]').change -> $form.submit()
    $form.transloadit
      wait: true
      modal: false
      autoSubmit: false
      onStart: -> $i.find('.spinner').show()
      onSuccess: (data) ->
        $i.find('.spinner').hide()
        image_url = data.results.w80[0].url
        $i.find('img.avatar').attr('src', image_url).end()
          .find('input').val(image_url).end()

    # button clicks trigger file upload
    $i.find('button').click (e) ->
      e.preventDefault()
      $file.click()
    .show()

$(load)
$(document).bind 'end.pjax', load
