require "lib/backbone_extensions.js"

module.exports = class WorkDayView extends Backbone.View
  top_tpl:    require "./templates/work_day/top"
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
      ko.applyBindings @view, $("header.row")[0]

  render: =>
    $("#main").html(@template())
    $("header.row").html(@top_tpl())
    $("#side").html @totals_tpl()
    $(window).oneTime 100, () -> $(document).foundationNavigation()

class WorkDayViewModel

  constructor: (year, month, day) ->
    @collection = ko.observableArray()
    last_day = new Date(year, month, 0).getDate()
    @day = ko.observable day
    @days = ko.observableArray([1..last_day])
    @year = ko.observable year
    @month = ko.observable month
    max_year = moment(new Date()).year()
    @years = ko.observableArray([2002..(Math.max(max_year, parseInt(year)))].reverse())
    @months = ko.observableArray ($.map ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"], (el, i) -> name: el, value: i + 1 )

    @backDay = =>
      date = moment()
      date.year(year)
      date.date(day)
      date.month(parseInt(month)-1)
      date.subtract('days', 1);

      Backbone.history.navigate "/#entries/#{date.year()}/#{date.month() + 1}/#{date.date()}", true
    @nextDay = =>
      date = moment()
      date.year(year)
      date.date(day)
      date.add('days', 1);
      date.month(parseInt(month)-1)

      Backbone.history.navigate "/#entries/#{date.year()}/#{date.month() + 1}/#{date.date()}", true
    @year.subscribe (y) ->
      if y.toString() != year
        Backbone.history.navigate "/#entries/#{y}/#{month}/#{day}", true
    @month.subscribe (m) ->
      if m.toString() != month
        date = moment()
        date.year(year)
        date.month((parseInt(m)-1))
        date.date(day)

        jump_day = day
        if date.month() != (parseInt(m) - 1)
          jump_day = new Date(year, parseInt(m), 0).getDate()

        Backbone.history.navigate "/#entries/#{year}/#{m}/#{jump_day}", true
    @day.subscribe (d) ->
      if d.toString() != day
        Backbone.history.navigate "/#entries/#{year}/#{month}/#{d}", true


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
    @new_day = moment.utc [year, month-1, day]
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
    "/#entries/#{@new_day.year()}/#{@new_day.month() + 1}/#{@new_day.date()}/new"
