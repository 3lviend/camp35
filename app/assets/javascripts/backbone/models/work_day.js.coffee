class TimesheetApp.Models.WorkDay extends Backbone.Model
  data_url:  =>
      date = moment (new Date @get("date"))
      "#entries/#{date.year()}/#{date.month()}/#{date.date()}"

  date_string: =>
      date = moment (new Date @get("date"))
      "#{date.format('YYYY-MM-DD, dddd')}"

  time_string: =>
    [hours, minutes] = @get("time").split(":")
    "#{parseInt hours}h #{parseInt minutes}m"

  day_name: (day) ->
    switch day
      when 0 then "Sunday"
      when 1 then "Monday"
      when 2 then "Tuesday"
      when 3 then "Wednesday"
      when 4 then "Thursday"
      when 5 then "Friday"
      when 6 then "Saturday"

class TimesheetApp.Collections.WorkDaysCollection extends Backbone.Collection
  model: TimesheetApp.Models.WorkDay
  url:   "/work_days/0"

