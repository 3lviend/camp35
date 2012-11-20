class TimesheetApp.Helpers.TimeInterval
  constructor: (@hours, @minutes) ->

  to_s: (format) ->
    switch format
      when "decimal" then "#{@hours}.#{@minutes*100/60}"
      else
        throw "Unrecognized format: #{format}"
