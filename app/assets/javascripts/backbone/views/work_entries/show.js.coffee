TimesheetApp.Views.WorkEntries ||= {}

class TimesheetApp.Views.WorkEntries.IndexView extends Backbone.View
  template:   JST["backbone/templates/work_entries/show"]
  totals_tpl: JST["backbone/templates/work_entries/_totals"]

  initialize: ->
    @view = new TimesheetApp.Views.WorkEntries.IndexViewModel(@options.year, @options.month, @options.day)
    @collection = @options.collection
    @collection.on "reset", =>
      @render()
      @collection.each (entry) =>
        @view.collection.push entry
      ko.applyBindings(@view)

  render: =>
    $("#main").html(@template())
    $("header.row").html "<h1>Work entries for the day</h1><h4>Take a peek at what you've accomplished</h4>"
    $("#side").html @totals_tpl()

class TimesheetApp.Views.WorkEntries.IndexViewModel

  constructor: (year, month, day) ->
    @collection = ko.observableArray()
    @billable = ko.computed =>
      hours = _.reduce @collection(), ((memo, e) -> memo + e.billable_hours()), 0
      minutes = _.reduce @collection(), ((memo, e) -> memo + e.billable_minutes()), 0
      moment.utc("00:00:00", "HH:mm:ss").add('hours', hours).add('minutes', minutes).format("HH:mm")
    @nonbillable = ko.computed =>
      hours = _.reduce @collection(), ((memo, e) -> memo + e.nonbillable_hours()), 0 
      minutes = _.reduce @collection(), ((memo, e) -> memo + e.nonbillable_minutes()), 0
      moment.utc("00:00:00", "HH:mm:ss").add('hours', hours).add('minutes', minutes).format("HH:mm")
    @total = ko.computed =>
      hours = _.reduce @collection(), ((memo, e) -> memo + parseInt(e.hours(), 10)), 0 
      minutes = _.reduce @collection(), ((memo, e) -> memo + parseInt(e.minutes(), 10)), 0
      moment.utc("00:00:00", "HH:mm:ss").add('hours', hours).add('minutes', minutes).format("HH:mm")
    @day = moment.utc [year, month, day]
    @collection.removeAll()
    @
  new_url: =>
    "/#entries/#{@day.year()}/#{@day.month()}/#{@day.date()}/new"
