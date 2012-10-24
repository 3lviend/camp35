TimesheetApp.Views.WorkEntries ||= {}

class TimesheetApp.Views.WorkEntries.IndexView extends Backbone.View
  template: JST["backbone/templates/work_entries/show"]

  initialize: ->
    @view = new TimesheetApp.Views.WorkEntries.IndexViewModel(@options.year, @options.month, @options.day)
    @collection = @options.collection
    @collection.on "reset", =>
      @render()
      @collection.each (entry) =>
        @view.collection.push entry
      ko.applyBindings(@view)

  render: =>
    $("section[role=main] .row").html(@template())

class TimesheetApp.Views.WorkEntries.IndexViewModel
  collection: ko.observableArray()
  constructor: (year, month, day) ->
    @day = moment [year, month, day]
    @collection.removeAll()
  new_url: =>
    "/#entries/#{@day.year()}/#{@day.month()}/#{@day.date()}/new"
