class TimesheetApp.Models.WorkMonth extends Backbone.Model
  defaults:
    year: 2012
    month: 11
    available: 160
    billable_total: "80h 0m"
    nonbillable_total: "80h 0m"
    total: "160h 0m"
  available_string: => "#{@get('available')}h 0m".format_interval()
  total_string: => @get('total').format_interval()
  billable_string: => @get('billable_total').format_interval()
  nonbillable_string: => @get('nonbillable_total').format_interval()
  month_year_string: => moment.utc([@get('year'), @get('month') - 1, 1]).format("MMMM YYYY")
  front_url: => "/#calendar/#{@get('year')}/#{@get('month')}"
  month_class: =>
    date = moment()
    if @get('month') > date.month() + 1
      'month-notyet'
    else 
      if @get('month') == date.month() + 1
        'month-current'
      else
        total_hours = parseInt(@get('total').split(" ")[0])
        if total_hours >= @get('available')
          'month-ok'
        else
          'month-little'

class TimesheetApp.Collections.WorkMonthsCollection extends Backbone.Collection
  model: TimesheetApp.Models.WorkMonth
  url: "/work_months"

