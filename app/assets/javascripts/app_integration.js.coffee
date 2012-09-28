# Custom code intended to fix things to play well with turbolinks

setupElements = ->
  $(document).foundationTopBar()
  $("textarea").autogrow()
#  $i(".remove").click (e) ->
 #   console.info e
  #  message = $(e.currentTarget).attr("data-confirm")
   # if confirm(message)
      
    #return false

$ ->
  setupElements()
  $(document).bind("page:change", setupElements)
