/*
  This widget shows Recent Posts on your Tumblr blog.
  Its dependency is jQuery.

  Usage:

    1) Add html:
      <div id="recent-posts"></div>

    2) Add code into the <head>:
      <script type='text/javascript' src='https://raw.github.com/gist/4056588'></script>

      <script type='text/javascript'
        $(function() { new Tumblr.RecentPosts($("#recent-posts")).render() })
      </script>

  It supports also second parameter specifying the posts count (default is 10).

  License:
  Copyright (c) 2012 Jarmo Pertman

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

var Tumblr = Tumblr || {};

Tumblr.RecentPosts = function(el, postsCount) {
  var apiUrl = "http://blog.nodeknockout.com/api/read/json?callback=?&filter=text&num=" + (postsCount || 10);

  var titleTypes = {
    regular: "regular-title",
    link: "link-text",
    quote: "quote-source",
    photo: "photo-caption",
    conversation: "conversation-title",
    video: "video-caption",
    audio: "audio-caption",
    answer: "question"
  };

  var renderPosts = function(posts) {
    return $.map($.map(posts, postInfo), renderPost);
  };

  var renderPost = function(post) {
    return "<li><a href='" + post.url + "'>" + post.title + "</a></li>";
  };

  var postInfo = function(post) {
    var titleType = titleTypes[post.type];
    if (titleType in post) {
      return {
        title: post[titleType],
        url: post["url-with-slug"]
      };
    }
  };

  return {
    render: function() {
      var loadingEl = $("<div>").text("Loading...").appendTo($(el));
      $.getJSON(apiUrl, function(data) {
        loadingEl.remove();
        $("<ul class='recent-posts'>").appendTo($(el)).hide().append(renderPosts(data.posts).join("\n")).slideDown('slow');
      });

      return this;
    }
  }
};