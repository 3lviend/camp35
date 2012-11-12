
TimesheetApp.Views.Home ||= {}

class TimesheetApp.Views.Home.IndexView extends Backbone.View
  template: JST["backbone/templates/home/index"]

  initialize: () ->
    @view = new TimesheetApp.Views.IndexViewModel()
    @collection = @options.collection
    @collection.on "reset", =>
      @render()
      @collection.each (day) =>
        @view.days.push day
      ko.applyBindings(@view)

  render: () ->
    $(@el).html(@template())
    $("#side").html("")
    $("header.row").html("<h1>Work days for the month</h1><h4>Gauge your work</h4>")
    $("#main").html(@el)
    ko.applyBindings(@view)

class TimesheetApp.Views.IndexViewModel
  constructor: ->
    date = moment.utc("2012-11-01")
    days = []
    #while date.month() + 1 == 11
    #  days.push (new TimesheetApp.Models.WorkDay(date: date.format("YYYY-MM-DD")))
    #  date.add('days', 1)
    @days = ko.observableArray(days)
    @goto = (e) =>
      Backbone.history.navigate e.href(), true