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
    today = moment.utc(new Date())
    if date.year() == today.year() && date.month() == today.month() && date.date() == today.date()
      "status-today"
    else
      if date.diff( (moment.utc(new Date()))) > 0 || date.day() == 6 || date.day() == 0
        "status-notyet"
      else
        if parseInt(@get("time").split(":")[0], 10) < 8
          "status-little"
        else
          "status-ok" # TODO: add real calculations

  date_class: (year, month) =>
    date = moment.utc(@get("date"))
    today = moment.utc(new Date())
    "day-#{date.day()} week-#{@week_of_date(date, year, month)} #{'today' if date.year() == today.year() && date.month() == today.month() && date.date() == today.date()} #{'weekend' if date.day() == 0 || date.day() == 6} #{'out-of-month' if date.month() + 1 != month}"

  week_of_date: (date, year, month) =>
    console.info date
    console.info year
    console.info month
    m = parseInt month
    if (date.month() + 1 < m && date.year() == year) || date.year() < year
      1
    else
      if date.month() + 1 > m || year < date.year()
        _date = moment([date.year(), date.month(), 1])
        _date.subtract('months', 1)
        _date.endOf('month')
        # _date.subtract('days', 1)
        Math.ceil((_date.date() + moment(_date).date(1).day())/7)
      else
        Math.ceil((date.date() + moment(date).date(1).day())/7)

  href: =>
    date = moment.utc(@get("date"))
    "/#entries/#{date.year()}/#{date.month() + 1}/#{date.date()}"

class TimesheetApp.Collections.WorkDaysCollection extends Backbone.Collection
  model: TimesheetApp.Models.WorkDay
  url:   "/work_days/0"

