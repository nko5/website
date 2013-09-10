jQuery ($) ->
  if $("#tumblr-posts").length > 0
    new Tumblr.RecentPosts($("#tumblr-posts")).render()