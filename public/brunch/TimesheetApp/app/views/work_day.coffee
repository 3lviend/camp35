require "lib/backbone_extensions.js"

module.exports = class WorkDayView extends Backbone.View
  template:   require "./templates/work_day/show"
  totals_tpl: require "./templates/work_day/totals"

  initialize: ->
    @view = new WorkDayViewModel(@options.year, @options.month, @options.day)
    @collection = @options.collection
    @collection.on "reset", =>
      @render()
      @collection.each (entry) =>
        @view.collection.push entry
      ko.applyBindings @view, $("#main")[0]
      ko.applyBindings @view, $("#side")[0]

  render: =>
    $("#main").html(@template())
    $("header.row").html "<h1>Work entries for #{@view.day.format('dddd, MMM Do YYYY')}</h1><h4>Take a peek at what you've accomplished</h4>"
    $("#side").html @totals_tpl()
    $(window).oneTime 100, () -> $(document).foundationNavigation()

class WorkDayViewModel

  constructor: (year, month, day) ->
    @collection = ko.observableArray()
    # serious refactor needed here!
    @billable = ko.computed =>
      hours = _.reduce @collection(), ((memo, e) -> memo + e.billable_hours()), 0
      minutes = _.reduce @collection(), ((memo, e) -> memo + e.billable_minutes()), 0
      moment.utc("00:00:00", "HH:mm:ss").add('hours', hours).add('minutes', minutes).format("HH:mm").format_interval()
    @nonbillable = ko.computed =>
      hours = _.reduce @collection(), ((memo, e) -> memo + e.nonbillable_hours()), 0 
      minutes = _.reduce @collection(), ((memo, e) -> memo + e.nonbillable_minutes()), 0
      moment.utc("00:00:00", "HH:mm:ss").add('hours', hours).add('minutes', minutes).format("HH:mm").format_interval()
    @total = ko.computed =>
      hours = _.reduce @collection(), ((memo, e) -> memo + parseInt(e.hours(), 10)), 0 
      minutes = _.reduce @collection(), ((memo, e) -> memo + parseInt(e.minutes(), 10)), 0
      moment.utc("00:00:00", "HH:mm:ss").add('hours', hours).add('minutes', minutes).format("HH:mm").format_interval()
    @day = moment.utc [year, month-1, day]
    @collection.removeAll()
    @redirect_to_entry = (entry) =>
      window.app.router.navigate entry.front_url(), trigger:true
      false
    @delete_entry = (entry) =>
      if confirm("Do you really want to remove work entry?")
        entry.delete_async
          success: ->
            humane.log "Work entry successfully deleted"
            Backbone.history.refresh()
          error: (err) ->
            humane.error "Error: #{err}"
    @entry_settings = (entry) =>
     false

    @
  redirect_to_new: => window.app.router.navigate @new_url(), trigger:true
  new_url: =>
    "/#entries/#{@day.year()}/#{@day.month() + 1}/#{@day.date()}/new"
