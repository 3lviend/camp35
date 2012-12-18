require "../lib/string_extensions.js"

module.exports = class CalendarView extends Backbone.View
  template: require "./templates/calendar/index"
  top_tpl:  require "./templates/calendar/top"

  initialize: () ->
    @view = new CalendarViewModel(@options.year, @options.month)
    @collection = @options.collection
    @collection.on "reset", =>
      @render()
      #@collection.each (day) =>
      #  @view.days.push day
      @view.days(@collection.models)
      # ko.applyBindings(@view, @el)
    @months = @options.months
    @months.on "reset", =>
      @view.work_months(@months.models)

  render: () ->
    $(@el).html(@template())
    $("#side").html("")
    $("header.row").html(@top_tpl())
    $("#main").html(@el)
    ko.applyBindings(@view, $("#main")[0])
    ko.applyBindings(@view, $("header.row")[0])

class CalendarViewModel
  constructor: (year, month) ->
    date = moment("2012-11-01")
    days = []
    @days = ko.observableArray(days)
    @work_months = ko.observableArray([])
    @week_totals = ko.computed () =>
      grouped = _.groupBy @days(), (day) =>
        date = moment.utc(day.get("date"))
        week = day.week_of_date(date, parseInt(year, 10), parseInt(month,10))
        # console.info "#{date.toDate().toDateString()} week: #{week}"
        week
        # all this need serious refactor
      reduceTime = (memo, time) =>
        # memo is in "0h 0m" format
        [mh, mm] = _.map memo.split(" "), (i) -> parseInt(i, 10)
        [hours, minutes] = _.map time.split(":"), (i) -> parseInt(i, 10)
        nm = mm + minutes
        nh = mh + hours
        if nm >= 60
          nh = nh + 1
          nm = nm - 60
        "#{nh}h #{nm}m"
      _.map _.values(grouped), (days) =>
        total: (_.reduce (_.map(days, (day) => day.get("time"))), reduceTime, "0h 0m").format_interval()
        billable_total: (_.reduce (_.map(days, (day) => day.get("billable_time"))), reduceTime, "0h 0m").format_interval()
        nonbillable_total: (_.reduce (_.map(days, (day) => day.get("nonbillable_time"))), reduceTime, "0h 0m").format_interval()
        total_class: () =>
          date = moment(days[0].get("date"))
          if date > moment.utc()
            'total-notyet'
          else if moment.utc(_.last(days).get("date")) > moment.utc() && date < moment.utc()
            'total-thisweek'
          else
            total = (_.reduce (_.map(days, (day) => day.get("time"))), reduceTime, "0h 0m")
            [hours, minutes] = total.split(" ")
            if parseInt(hours, 10) >= 40
              'total-ok'
            else
              'total-little'
    @year = ko.observable year
    @month = ko.observable month
    max_year = moment(new Date()).year()
    @years = ko.observableArray([2002..(Math.max(max_year, parseInt(year)))].reverse())
    @months = ko.observableArray ($.map ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], (el, i) -> name: el, value: i + 1 )
    @goto = (e) =>
      Backbone.history.navigate e.href(), true
    @year.subscribe (y) ->
      if y.toString() != year
        Backbone.history.navigate "/#calendar/#{y}/#{month}", true
    @month.subscribe (m) ->
      if m.toString() != month
        Backbone.history.navigate "/#calendar/#{year}/#{m}", true
    @redirect_to_month = (month) =>
      window.app.router.navigate month.front_url(), trigger:true
    @backMonth = =>
      date = moment()
      date.year(year)
      date.month(parseInt(month) - 1)
      date.subtract('months', 1)
      Backbone.history.navigate "/#calendar/#{date.year()}/#{date.month() + 1}", true
    @nextMonth = =>
      date = moment()
      date.year(year)
      date.month(parseInt(month) - 1)
      date.add('months', 1)
      Backbone.history.navigate "/#calendar/#{date.year()}/#{date.month() + 1}", true
