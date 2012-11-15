
TimesheetApp.Views.Home ||= {}

class TimesheetApp.Views.Home.IndexView extends Backbone.View
  template: JST["backbone/templates/home/index"]
  top_tpl:  JST["backbone/templates/home/_top"]

  initialize: () ->
    @view = new TimesheetApp.Views.IndexViewModel(@options.year, @options.month)
    @collection = @options.collection
    @collection.on "reset", =>
      @render()
      #@collection.each (day) =>
      #  @view.days.push day
      @view.days(@collection.models)
      ko.applyBindings(@view)
    @months = @options.months
    @months.on "reset", =>
      @view.work_months(@months.models)

  render: () ->
    $(@el).html(@template())
    $("#side").html("")
    $("header.row").html(@top_tpl())
    $("#main").html(@el)
    ko.applyBindings(@view)

class TimesheetApp.Views.IndexViewModel
  constructor: (year, month) ->
    date = moment.utc("2012-11-01")
    days = []
    @days = ko.observableArray(days)
    @work_months = ko.observableArray([])
    @week_totals = ko.computed () =>
      grouped = _.groupBy @days(), (day) =>
        date = moment.utc(day.get("date"))
        week = day.week_of_date(date, parseInt(year, 10), parseInt(month,10))
        console.info "#{date.toDate().toDateString()} week: #{week}"
        week
      console.info grouped
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
        total: (_.reduce (_.map(days, (day) => day.get("time"))), reduceTime, "0h 0m")
        billable_total: (_.reduce (_.map(days, (day) => day.get("billable_time"))), reduceTime, "0h 0m")
        nonbillable_total: (_.reduce (_.map(days, (day) => day.get("nonbillable_time"))), reduceTime, "0h 0m")
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
    max_year = moment.utc(new Date()).year()
    @years = ko.observableArray([2002..(Math.max(max_year, parseInt(year)))].reverse())
    @months = ko.observableArray ($.map ["January", "February", "March", "April", "Mai", "June", "July", "August", "September", "October", "November", "December"], (el, i) -> name: el, value: i + 1 )
    @goto = (e) =>
      Backbone.history.navigate e.href(), true
    @year.subscribe (y) ->
      if y.toString() != year
        Backbone.history.navigate "/#calendar/#{y}/#{month}", true
    @month.subscribe (m) ->
      if m.toString() != month
        Backbone.history.navigate "/#calendar/#{year}/#{m}", true
    @backMonth = =>
      date = moment.utc()
      date.year(year)
      date.month(parseInt(month) - 1)
      date.subtract('months', 1)
      Backbone.history.navigate "/#calendar/#{date.year()}/#{date.month() + 1}", true
    @nextMonth = =>
      date = moment.utc()
      date.year(year)
      date.month(parseInt(month) - 1)
      date.add('months', 1)
      Backbone.history.navigate "/#calendar/#{date.year()}/#{date.month() + 1}", true