class TimesheetApp.Models.WorkDay extends Backbone.Model
  data_url:  =>
      date = moment.utc (new Date @get("date"))
      "#entries/#{date.year()}/#{date.month() + 1}/#{date.date()}"

  date_string: =>
      date = moment.utc (new Date @get("date"))
      "#{date.format('YYYY-MM-DD, dddd')}"

  time_string: =>
    if @get("time")
      [hours, minutes] = @get("time").split(":")
      "#{parseInt hours, 10}h #{parseInt minutes, 10}m"
    else
      date = moment.utc(@get("date"))
      if date.day() == 0 || date.day() == 6
        ""
      else
        "0h 0m"

  billable_time_string: =>
    if @get("time")
      [hours, minutes] = @get("billable_time").split(":")
      "#{parseInt hours, 10}h #{parseInt minutes, 10}m"
    else
      date = moment.utc(@get("date"))
      if date.day() == 0 || date.day() == 6
        ""
      else
        "0h 0m"

  nonbillable_time_string: =>
    if @get("time")
      [hours, minutes] = @get("nonbillable_time").split(":")
      "#{parseInt hours, 10}h #{parseInt minutes, 10}m"
    else
      date = moment.utc(@get("date"))
      if date.day() == 0 || date.day() == 6
        ""
      else
        "0h 0m"

  day_name: (day) ->
    switch day
      when 0 then "Sunday"
      when 1 then "Monday"
      when 2 then "Tuesday"
      when 3 then "Wednesday"
      when 4 then "Thursday"
      when 5 then "Friday"
      when 6 then "Saturday"

  day: =>
    moment.utc(@get("date")).date()

  status_class: =>
    date = moment.utc(@get("date"))
    if date.toDate().toDateString() == (new Date()).toDateString()
      "status-today"
    else
      if date.date() > (moment.utc(new Date())).date() || date.day() == 6 || date.day() == 0
        "status-notyet"
      else
        if parseInt(@get("time").split(":")[0], 10) < 8
          "status-little"
        else
          "status-ok" # TODO: add real calculations

  date_class: =>
    date = moment.utc(@get("date"))
    "day-#{date.day()} week-#{@week_of_date(date)} #{'today' if (date.toDate().toDateString() == (new Date()).toDateString())} #{'weekend' if date.day() == 0 || date.day() == 6}"

  week_of_date: (date) =>
    Math.ceil((date.date() + moment(date).date(1).day())/7)

  href: =>
    date = moment.utc(@get("date"))
    "/#entries/#{date.year()}/#{date.month() + 1}/#{date.date()}"

class TimesheetApp.Collections.WorkDaysCollection extends Backbone.Collection
  model: TimesheetApp.Models.WorkDay
  url:   "/work_days/0"

