# Custom code intended to fix things to play well with turbolinks

setupElements = ->
  $(document).foundationTopBar()
  $("textarea").autoGrow()
  $("#spinner").stop()
  $(".calendar").datepicker
    dateFormat: "yy/mm/dd"

$ ->
  setupElements()
  $(document).bind("page:change", setupElements)
  $(document).bind "page:fetch", ->
    $("#spinner").spin
      color: "#fff"
      top: 3
      radius: 8
      width: 3
      shadow: true
      zIndex: 9e9
    
