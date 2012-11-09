
TimesheetApp.Views.Home ||= {}

class TimesheetApp.Views.Home.IndexView extends Backbone.View
  template: JST["backbone/templates/home/index"]

  initialize: () ->
    @view = new TimesheetApp.Views.IndexViewModel()

  render: () ->
    $(@el).html(@template())
    $("#main").html(@el)
    ko.applyBindings(@view)

class TimesheetApp.Views.IndexViewModel
  constructor: ->
    date = moment.utc("2012-11-01")
    days = []
    while date.month() + 1 == 11
      days.push (new TimesheetApp.Models.WorkDay(date: date.format("YYYY-MM-DD")))
      date.add('days', 1)
    @days = ko.observableArray(days)
    console.info days