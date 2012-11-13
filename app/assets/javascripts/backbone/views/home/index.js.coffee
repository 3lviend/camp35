
TimesheetApp.Views.Home ||= {}

class TimesheetApp.Views.Home.IndexView extends Backbone.View
  template: JST["backbone/templates/home/index"]
  top_tpl:  JST["backbone/templates/home/_top"]

  initialize: () ->
    @view = new TimesheetApp.Views.IndexViewModel(@options.year, @options.month)
    @collection = @options.collection
    @collection.on "reset", =>
      @render()
      @collection.each (day) =>
        @view.days.push day
      ko.applyBindings(@view)

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
    #while date.month() + 1 == 11
    #  days.push (new TimesheetApp.Models.WorkDay(date: date.format("YYYY-MM-DD")))
    #  date.add('days', 1)
    @days = ko.observableArray(days)
    @year = ko.observable year
    @month = ko.observable month
    max_year = moment.utc(new Date()).year()
    @years = ko.observableArray([1995..(Math.max(max_year, parseInt(year)))].reverse())
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