(function() {
  var load = function() {
    $('#page.index-tell-me-a-story').each(function() {
      // edge flip when moving around
      var scrolling = false;
      if (!Modernizr.touch)
        $(window)
          .on('click', function(e) {
            if (e.pageX === undefined || e.pageY === undefined) return;
            var pos = { x: e.pageX, y: e.pageY }
              , $win = $(this)
              , left = $win.scrollLeft()
              , top = $win.scrollTop()
              , right = left + $win.width()
              , bottom = top + $win.height()
              , buffer = 160
              , newLeft = left, newTop = top;

            if (pos.x < left + buffer)
              newLeft = left - $win.width()/2;
            else if (pos.x > right - buffer)
              newLeft = left + $win.width()/2;

            if (pos.y < top + buffer)
              newTop = top - $win.height()/2;
            else if (pos.y > bottom - buffer)
              newTop = top + $win.height()/2;

            scrolling = true;
            $('body')
              .stop()
              .animate({ scrollLeft: newLeft, scrollTop: newTop }, 800);
          })
          .on('mousewheel', function(e) {
            if (scrolling) {
              $('body').stop();
              scrolling = false;
            }
          });

      // #target links: warp to target
      $('a[href^="#"]').on('click', function(e) {
        var href = $(this).attr('href');
        if (href === '#') return;

        e.stopPropagation();
        nko.warpTo(href);
      });

      // popup for image links
      $('.slide').each(function() {
        $('a[href$=".png"]', this)
          .attr('rel', this.id)
          .fancybox({ padding: 0 });
      });

      // more flare
      new nko.IdleThing({ name: 'fire', pos: new nko.Vector(2300, 360) });
      nko.map([
        // slide 0 - story time
        { 'livetree':   [ 1860, 200 ] },
        { 'deadtree':   [ 1800, 300 ] },
        { 'livetree':   [ 1920, 500 ] },
        { 'arrowright': [ 2570, 560 ] },
        { 'deadtree':   [ 2600, 20  ] },
        { 'tent':       [ 2000, 330 ] },
        { 'log':        [ 2230, 420 ] },
        { 'log':        [ 2360, 330 ] },

        // slide 1 - rails rumble 2008
        { 'livetree': [ 3900, 250 ] },
        { 'livetree': [ 3960, 450 ] },
        { 'livetree': [ 3800, 550 ] },
        { 'deadtree': [ 3950, 870 ] },

        // slide 2 - <3 hackathons
        { 'baretree':  [ 4000, 960  ] },
        { 'livetree':  [ 3870, 1470 ] },
        { 'livetree':  [ 3980, 1630 ] },
        { 'arrowleft': [ 2950, 1600 ] },

        // slide 3 - rails rumble 2009
        { 'livetree': [ 1740, 1770 ] },
        { 'livetree': [ 1820, 1650 ] },
        { 'livetree': [ 2480, 1930 ] },
        { 'portopotty': [ 2630, 1520 ] },
        { 'portopotty': [ 2700, 1520 ] },

        // slide 4 - "rails"?
        { 'livetree': [ 840, 1120 ] },
        { 'log':      [ 890, 1150 ] },

        // slide 5 - forcing 2009 to be realtime
        { 'deadtree': [ 760, 2560 ] },
        { 'deadtree': [ 810, 2360 ] },
        { 'baretree': [ 740, 2240 ] },

        // slide 6 - omg node
        { 'livetree': [  870, 3370 ] },
        { 'livetree': [  940, 3600 ] },
        { 'livetree': [ 1100, 3810 ] },
        { 'obelisk':  [  820, 3170 ] },

        // slide 7 - omg dilemma
        { 'livetree': [ 2520, 3700 ] },
        { 'deadtree': [ 2750, 3460 ] },
        { 'baretree': [ 2710, 3250 ] },
        { 'deadtree': [ 2820, 3100 ] },

        // slide 8 - reenactment
        { 'livetree': [ 1860, 2140 ] },
        { 'deadtree': [ 1830, 2400 ] },
        { 'livetree': [ 1900, 2580 ] },
        { 'hachiko':  [ 2000, 2360 ] },

        // slide 9 - nko1
        { 'livetree':   [ 2780, 1990 ] },
        { 'arrowright': [ 2520, 2510 ] },
        { 'deadtree':   [ 2750, 2760 ] },
        { 'chair':      [ 2930, 2410 ] },

        // slide 10 - 2012 winners
        { 'livetree': [ 4720, 2790 ] },
        { 'deadtree': [ 4790, 2660 ] },

        // slide 11 - 2011 winners
        { 'livetree': [ 5900, 2100 ] },
        { 'livetree': [ 5970, 2360 ] },
        { 'livetree': [ 5810, 2900 ] },
        { 'desk':     [ 5830, 2150 ] },

        // slide 12 - 2012
        { 'livetree':   [ 5750, 3140 ] },
        { 'livetree':   [ 5660, 3460 ] },
        { 'livetree':   [ 5720, 3600 ] },
        { 'streetlamp': [ 5640, 3550 ] },

        // slide 13 - nko3 changes
        { 'livetree':   [ 3800, 3300 ] },
        { 'livetree':   [ 3760, 3600 ] },
        { 'streetlamp': [ 3970, 3330 ] },

        // slide 14 - thanks
        { 'livetree':     [ 4610, 4000 ] },
        { 'livetree':     [ 4550, 4140 ] },
        { 'deadtree':     [ 4630, 4290 ] },

        {}
      ]);
    });
  };

  $(load);
  $(document).on('end.pjax', load);
})();
