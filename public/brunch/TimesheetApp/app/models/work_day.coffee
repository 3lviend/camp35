module.exports = class WorkDay extends Backbone.Model
  data_url:  =>
      date = moment.utc (new Date @get("date"))
      "#entries/#{date.year()}/#{date.month() + 1}/#{date.date()}"

  date_string: =>
      date = moment.utc (new Date @get("date"))
      "#{date.format('YYYY-MM-DD, dddd')}"

  in_future: =>
    date = moment(@get("date"))
    now  = moment(new Date())
    if date.year() > now.year()
      true
    else
      if date.year() < now.year()
        false
      else
        if date.month() > now.month()
          true
        else
          if date.month() < now.month()
            false
          else
            if date.date() > now.date()
              true
            else
              false

  time_string: =>
    if @get("time")
      # [hours, minutes] = @get("time").split(":")
      # "#{parseInt hours, 10}h #{parseInt minutes, 10}m"
      @get("time").format_interval()
    else
      date = moment.utc(@get("date"))
      if date.day() == 0 || date.day() == 6
        ""
      else
        "0h 0m".format_interval()

  billable_time_string: =>
    if @get("billable_time")
      @get("billable_time").format_interval()
    else
      date = moment.utc(@get("date"))
      if date.day() == 0 || date.day() == 6
        ""
      else
        "0h 0m".format_interval()

  nonbillable_time_string: =>
    if @get("nonbillable_time")
      @get("nonbillable_time").format_interval()
    else
      date = moment.utc(@get("date"))
      if date.day() == 0 || date.day() == 6
        ""
      else
        "0h 0m".format_interval()

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
    moment(@get("date")).date()

  status_class: =>
    return "status-has-zero" if @get("has_zero")
    date = moment(@get("date"))
    today = moment(new Date())
    if date.year() == today.year() && date.month() == today.month() && date.date() == today.date()
      "status-today"
    else
      if date.diff( (moment(new Date()))) > 0 || date.day() == 6 || date.day() == 0
        if parseInt(@get("time").split(":")[0], 10) > 0
          "status-ok"
        else
          "status-notyet"
      else
        if parseInt(@get("time").split(":")[0], 10) < 8
          "status-little"
        else
          "status-ok"

  date_class: (year, month) =>
    date = moment(@get("date"))
    today = moment(new Date())
    "day-#{date.day()} week-#{@week_of_date(date, year, month)} #{'today' if date.year() == today.year() && date.month() == today.month() && date.date() == today.date()} #{'weekend' if date.day() == 0 || date.day() == 6} #{'out-of-month' if date.month() + 1 != month} #{@status_class()}"

  week_of_date: (date, year, month) =>
    # console.consoleinfo date
    # console.info year
    # # console.info month
    m = parseInt month
    y = parseInt year
    if (date.month() + 1 < m && date.year() == y) || date.year() < y
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


