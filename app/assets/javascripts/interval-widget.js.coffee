$ = jQuery

$.fn.extend

  interval: ->
    # we have to dress up input into span with 
    # plus and minus buttons
    span = $(this).wrap("<span class='interval-widget'></span>").parent()
    span.append("<a href='#' class='plus'>+</a>")
    span.append("<a href='#' class='minus'>-</a>")


    # so here we expect value like: "01:00:00"
    # and we return "1h 0m"
    rawToInterval = (value) ->
      vals = value.split(":")
      "#{vals[0]}h #{vals[1]}m"

    # here we get a value like: "2h 30m"
    # and return Date object with whatever date
    # but with hour set to 2 and minutes set to 30
    intervalToDate = (value) ->
      date = new Date()
      vals = value.replace(/[hm]/, "").split(" ")
      date.setHours(parseInt(vals[0]))
      date.setMinutes(parseInt(vals[1]))
      date

    dateToInterval = (date) ->
      hours = date.getHours()
      minutes = date.getMinutes()
      "#{hours}h #{minutes}m"

    return @each () ->

      value = rawToInterval($(this).val())
      input = this

      addMinutes = (minutes, v) ->
        date = intervalToDate(v)
        date.setMinutes(date.getMinutes() + minutes)
        value = dateToInterval(date)
        $(input).val(value)

      span.find(".plus").click (e) ->
        addMinutes(15, value)

      span.find(".minus").click (e) ->
        addMinutes(-15, value)

      addMinutes(0, value)
  
