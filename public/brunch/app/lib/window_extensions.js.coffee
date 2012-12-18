# Some useful extensions to the Window object making it easier
# to accomplish simple things that would require few lines of jQuery..
#

Window::scroll_top = ->
  $("html, body").animate({ scrollTop: 0 }, "slow")
