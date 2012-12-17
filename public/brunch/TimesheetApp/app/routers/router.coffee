WorkMonthsCollection = require 'collections/work_months'
WorkDaysCollection = require 'collections/work_days'
WorkEntriesCollection = require "collections/work_entries"

WorkEntry = require "models/work_entry"

CalendarView = require "views/calendar"
EntryNewView = require "views/entries/new"
EntryEditView = require "views/entries/edit"
WorkDayView = require "views/work_day"

module.exports = class Router extends Backbone.Router
  routes :
    '': 'root'
    'login': 'login'
    'calendar/:year/:month': 'home'
    'entry/:id': 'edit_entry'
    'entries/:year/:month/:day/new': 'new_entry'
    'work_days/:weeks_from_now': 'work_days'
    'entries/:year/:month/:day': 'work_day'
    'reports': 'reports'

  redirect: ->
    @navigate ''

  initialize: ->
    @on "admin:assume-other", () =>
      @current_role = app.current_role
      @current_role.fetch()
      app.rolesToSwitch.fetch()
    @modal = app.modal
    @navigate '/#', trigger:true

  before:
    '^((?!login).)*$': ->
        @render_navigation()
        app.current_role.fetch()
    'login': =>
        $(".top-bar").html("")

  render_navigation: ->
    app.topBarView.render()

  reports: ->
    app.rolesToReport.fetch()
    $(window).oneTime 100, => app.reportsView.render()

  login: ->
    $(window).oneTime 100, () => app.loginView.render()

  root: ->
    if window.location.pathname != "/users/sign_in"
      date = moment(new Date())
      @navigate "/#calendar/#{date.year()}/#{date.month() + 1}", trigger: true

  home: (year, month) ->
    months = new WorkMonthsCollection()
    days = new WorkDaysCollection()
    days.url = "/work_days/calendar/#{year}/#{month}.json"
    now = moment.utc([parseInt(year,10), parseInt(month, 10) - 1, 1])
    before = moment.utc(now).subtract('months', 5)
    months.url = "/work_months/#{before.format('YYYY-MM-01')}/#{now.format('YYYY-MM-01')}.json"
    view = new CalendarView(collection: days, year: year, month: month, months: months)
    days.fetch()
    months.fetch()

  new_entry: (year, month, day) ->
    day = moment.utc([year, month-1, day]).format("YYYY-MM-DD")
    entry = new WorkEntry(date_performed: day)
    entry.set("work_entry_durations", [
      duration: "00:00:00"
    ])
    view = new EntryNewView(model: entry)
    $(window).oneTime 100, () => view.render()

  edit_entry: (id) ->
    entry = new WorkEntry(id: id)
    view = new EntryEditView(model: entry, charts: @work_charts)
    entry.fetch()

  work_days: (weeks_from_now) ->
    days = new TimesheetApp.Collections.WorkDaysCollection()
    view = new TimesheetApp.Views.WorkDays.IndexView(collection: days, weeks_from_now: weeks_from_now)
    days.url = "/work_days/#{weeks_from_now}.json"
    days.fetch()

  work_day: (year, month, day) ->
    console.info "Work day"
    entries = new WorkEntriesCollection()
    view = new WorkDayView(collection: entries, year: year, month: month, day: day)
    entries.url = "/work_day_entries/#{year}/#{month}/#{day}.json"
    entries.fetch()

