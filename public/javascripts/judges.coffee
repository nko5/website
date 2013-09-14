$('#page.judges').each ->
  $('a.delete').click (e) ->
    if confirm('Are you sure?')
      $a = $(this)
      $.ajax $a.attr('href'),
        type: 'DELETE'
        success: ->
          $a.closest('li').slideUp()
    false


$('form.person .twitter input').live('blur', ->
  $this = $this
  $form = $this.closest('form')
  return $this.next('.spinner').hide() unless $this.val()

  $this.next('.spinner').show()
  # ws = io.connect null, {'port': '#socketIoPort#'})
  # ws.on 'userData', (userData) ->
  #   # $form.find('.name :text').val (i, v) -> v or data.name
  #   $this.next('.spinner').hide()
  #   # IM HERE!!!!!
  #   # 1. fill the data in the form
    # 2. test it




  # $.getJSON 'https://api.twitter.com/1.1/users/show.json?',
  #   screen_name: $.trim($this.val()),
  #   (data) ->
  #     $form.find('.name :text').val (i, v) -> v or data.name
  #     # $form.find('.location :text').val (i, v) -> v or data.location
      # $form.find('.bio textarea').text (i, t) -> t or data.description

      # unless $form.find('.image_url input').val()
      #   image_url = data.profile_image_url.replace '_normal.', '.'
      #   $form.find('.image_url')
      #     .find('img.avatar').attr('src', image_url).end()
      #     .find('input').val image_url

      
).change()
  

   # var ws = nko.ws = io.connect(null, {
   #    'port': '#socketIoPort#'
   #  });
   #  ws.on('connect', function() {
   #    me.id = ws.socket.sessionid;
   #    nko.dudes[me.id] = me;
   #    (function heartbeat() {
   #      nko.send({ obj: me }, true);
   #      setTimeout(heartbeat, 5000);
   #    })();
   #  });
   #  ws.on('message', function(data) {
   #    var dude = dudes[data.id];

   #    if (data.disconnect && dude) {
   #      dude.remove();
   #      delete dudes[data.id];
   #    }

   #    if (data.obj && !dude && data.obj.pos.x < 10000 && data.obj.pos.y < 10000)
   #      dude = dudes[data.id] = new nko.Dude(_.extend(data.obj, { id: data.id })).draw();

   #    if (dude && data.method) {
   #      dude.origin = data.obj.origin;
   #      var arguments = _.map(data.arguments, function(obj) {
   #        return obj.id ? nko.dudes[obj.id] : obj;
   #      });
   #      nko.Dude.prototype[data.method].apply(dude, arguments);
   #    }
   #  });
   #  nko.near = function near(pos) {
   #    return _.find(nko.dudes, function(dude) {
   #      return dude !== me && dude.near(pos);
   #    });
   #  };