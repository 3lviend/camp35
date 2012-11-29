class TimesheetApp.Helpers.TimeInterval
  constructor: (@hours, @minutes) ->

  to_s: (format) ->
    switch format
      when "decimal"
        hours_padded   = "#{@hours}".pad 2
        minutes_padded = "#{@minutes*100/60}".pad 2
        "#{hours_padded}.#{minutes_padded}"
      else
        throw "Unrecognized format: #{format}"
