load = ->
  $('#page.index-index').each ->  # TODO beware pjax throwing this off
    # server offset
    skew = 0
    $.get '/now', (server) -> skew = new Date(parseInt(server)) - new Date

    $('table.timeline').each ->
      $table = $(this)
      $current = $next = null

      toggleDetails = (tbody) ->
        details = $(tbody).find('.details').css('height', 'auto')
        if $(tbody).hasClass('current')
          details
            .height(details.height())
            .children().redraw()  # dirty, dirty hack
        else
          details.height 0

      setCurrent = (tbody) ->
        $('tbody.current', $table).removeClass('current')
        $current = $(tbody).addClass('current')

        $('tbody.next', $table).removeClass('next')
        $next = $current.next('tbody').addClass('next')

        $('.details', $table).height 0
        toggleDetails $current

      $table.on 'click', 'tr.header', (e) ->
        if e.altKey
          setCurrent $(this).closest('tbody')
        else
          toggleDetails $(this).closest('tbody').toggleClass('current')

      now = new Date
      $('tbody', $table).each ->
        $tbody = $(this)

        # translate to local time
        $time = $('[datetime]', this)
        $tbody.data 'moment', t = moment $time.attr('datetime')
        $time.text t.format('MMM DD LT')

        # add countdown td
        $('tr.header', this).append $('<td class="countdown">')

        # set which one is current
        if t < now
          $(this).addClass('old')
        else if $current is null
          setCurrent $(this).prev('tbody')

      # countdown
      parts = (s) ->
        s /= 1000
        _.map([s / 86400, s % 86400 / 3600, s % 3600 / 60, s % 60], Math.floor)
      pad = (s) -> if s >= 10 then s else '0' + s

      do tick = ->
        diff = $next.data('moment') - new Date - skew

        return if isNaN diff

        if diff > 0
          p = parts diff
          $countdown = $('td.countdown', $next).text 'in '
          $countdown.append "#{p[0]}d " if p[0]
          $countdown.append _.map(p[1..3], pad).join(':')

          setTimeout tick, 800
        else
          $next.addClass 'old'
          setCurrent $next
          tick()

$(load)
$(document).bind 'end.pjax', load
