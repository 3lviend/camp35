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
    dateFormat: "yy-mm-dd"
#  $(".spinner.hours").spinner
#    min: 0
#    max: 24
#    step: 1
#  $(".spinner.minutes").spinner
#    min: -15
#    max: 60
#    step: 15
#  # this is naive - should be refactored some day
  $(".spinner.minutes").change (e) ->
    if $(e.currentTarget).val() == "60"
      $(e.currentTarget).val("0")
      $(".spinner.hours").spinner("increment")
    else if $(e.currentTarget).val() == "-15"
      $(e.currentTarget).val("45")
      $(".spinner.hours").spinner("decrement")
  $(document).foundationButtons()
  window.startSpinner = startSpinner
  window.stopSpinner = stopSpinner
  stopSpinner()

$ ->
  setupElements()
  $(document).bind("page:change", setupElements)
  $(document).bind "page:fetch", startSpinner 
