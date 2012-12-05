# Extensions for various Backbone related classes

Backbone.History::refresh = ->
  Backbone.history.fragment = null
  Backbone.history.navigate(document.location.hash, true)
