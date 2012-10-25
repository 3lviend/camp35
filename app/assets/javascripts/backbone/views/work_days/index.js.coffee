TimesheetApp.Views.WorkDays ||= {}

class TimesheetApp.Views.WorkDays.IndexView extends Backbone.View
  template: JST["backbone/templates/work_days/index"]

  initialize: ->
    @view = new TimesheetApp.Views.WorkDays.IndexViewModel(@options.weeks_from_now)
    @collection = @options.collection
    @collection.on "reset", =>
      @render()
      @collection.each (day) =>
        @view.collection.push day
      ko.applyBindings(@view)

  render: =>
    $("#main").html(@template())

class TimesheetApp.Views.WorkDays.IndexViewModel
  collection: ko.observableArray()
  previous_href: ->
    "/#work_days/#{@current_week + 1}"
  next_href: ->
    "/#work_days/#{@current_week - 1}"
  constructor: (week) ->
    @current_week = parseInt week
    @collection.removeAll()
