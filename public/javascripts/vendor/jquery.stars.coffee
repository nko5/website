$.fn.stars = ->
  this.each -> new Stars(this)

class Stars
  constructor: (input) ->
    @el = $('<div class="stars">')
    @input = $(input).hide().after(@el)
      .change @leave # re-render on input change

    for [1..@input.attr('max')]
      $("<div class='star'>")
        .hover(@enter, @leave)
        .click(@click)
        .appendTo(@el)

    @render()

  disabled: -> @input.is(':disabled')

  stars: (star) -> $(star).prevAll('.star').length + 1

  enter: (e) =>
    return if @disabled()
    @render @stars e.target

  leave: (e) => @render()

  click: (e) =>
    return if @disabled()
    val = @stars e.target
    @input.val (i, v) ->
      if parseInt(v) isnt val then val else 0
    @render()

  render: (count=@input.val()) ->
    @el.children('.star').each (i) ->
      $(this).toggleClass 'filled', i < count
