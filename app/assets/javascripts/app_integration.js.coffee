# Custom code intended to fix things to play well with turbolinks

startSpinner = ->
    $("#spinner").spin
      color: "#fff"
      top: 3
      radius: 8
      width: 3
      shadow: true
      zIndex: 9e9
    if $("#spinner").css("display") == "none"
      $("#spinner").show()
      $("#spinner").css({left: "50%", position: "absolute"})

stopSpinner = -> 
  $("#spinner").stop()
  if $("#spinner").css("display") == "block"
    $("#spinner").hide()

setupElements = ->
  $(document).foundationTopBar()
  $("textarea").autoGrow()
  $(".calendar").datepicker
    dateFormat: "yy/mm/dd"
  window.startSpinner = startSpinner
  window.stopSpinner = stopSpinner
  stopSpinner()

$ ->
  setupElements()
  $(document).bind("page:change", setupElements)
  $(document).bind "page:fetch", startSpinner 
