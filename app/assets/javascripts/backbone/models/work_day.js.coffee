class TimesheetApp.Models.WorkDay extends Backbone.Model
  data_url:  =>
      date = moment.utc (new Date @get("date"))
      "#entries/#{date.year()}/#{date.month() + 1}/#{date.date()}"

  date_string: =>
      date = moment.utc (new Date @get("date"))
      "#{date.format('YYYY-MM-DD, dddd')}"

  time_string: =>
    [hours, minutes] = @get("time").split(":")
    "#{parseInt hours, 10}h #{parseInt minutes, 10}m"

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

