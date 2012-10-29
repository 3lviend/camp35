class TimesheetApp.Routers.MainRouter extends Backbone.Router
  routes :
    '': 'root'
    'login': 'login'
    'calendar': 'home'
    'entries/:id': 'edit_entry'
    'entries/:year/:month/:day/new': 'new_entry'
    'work_days/:weeks_from_now': 'work_days'
    'entries/:year/:month/:day': 'work_day'

  before:
    '^((?!login).)*$': ->
        console.info "not login route"
    'login': ->
        console.info "login route"

  login: ->
    view = new TimesheetApp.Views.Authentication.LoginView()
    $(window).oneTime 100, () => view.render()

  root: ->
    if window.location.pathname != "/users/sign_in"
      window.location.href = "/#work_days/0"

  home: ->
    view = new TimesheetApp.Views.Home.IndexView()
    $(window).oneTime 100, () => view.render()

  new_entry: (year, month, day) ->
    day = moment([year, month-1, day]).format("YYYY-MM-DD")
    entry = new TimesheetApp.Models.WorkEntry(date_performed: day)
    entry.set("work_entry_durations", [
      duration: "00:00:00"
    ])
    view = new TimesheetApp.Views.Entries.NewView(model: entry)
    $(window).oneTime 100, () => view.render()

  edit_entry: (id) ->
    entry = new TimesheetApp.Models.WorkEntry(id: id)
    view = new TimesheetApp.Views.Entries.EditView(model: entry, charts: @work_charts)
    entry.fetch()

  work_days: (weeks_from_now) ->
    days = new TimesheetApp.Collections.WorkDaysCollection()
    view = new TimesheetApp.Views.WorkDays.IndexView(collection: days, weeks_from_now: weeks_from_now)
    days.url = "/work_days/#{weeks_from_now}.json"
    days.fetch()

  work_day: (year, month, day) ->
    console.info "Work day"
    entries = new TimesheetApp.Collections.WorkEntriesCollection()
    view = new TimesheetApp.Views.WorkEntries.IndexView(collection: entries, year: year, month: month, day: day)
    entries.url = "/work_day_entries/#{year}/#{month}/#{day}.json"
    entries.fetch()


$.ajaxSetup
  statusCode:
    401: ->
      window.location.replace "/#login"
    403: ->
      window.location.replace "/#denied"
