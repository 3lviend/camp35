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

initSpinner = ->
    unless window.spin
      window.spin = new Spinner 
        lines: 13
        length: 7
        width: 4
        radius: 10
        corners: 1
        rotate: 0
        color: '#fff'
        speed: 1
        trail: 58
        shadow: true
        hwaccel: false
        className: 'spinner'
        zIndex: 2e9
        top: 'auto'
        left: 'auto'

startSpinner = ->
  initSpinner() unless window.spin
  $("li.name a").css("visibility", "hidden")
  window.spin.spin $("li.name")[0]

stopSpinner = ->
  $("li.name a").css("visibility", "visible")
  window.spin.stop()

$.ajaxSetup
  beforeSend: startSpinner
  complete:   stopSpinner
  statusCode:
    401: ->
      window.location.replace "/#login"
    403: ->
      window.location.replace "/#denied"

$(document).ajaxStop stopSpinner

$(document).ajaxStart ->
  startSpinner()

$ ->
  key 'command+n', ->
    date = moment()
    Backbone.history.navigate "/#entries/#{date.year()}/#{date.month()+1}/#{date.date()}/new", true
  key 'command+t', ->
    date = moment()
    Backbone.history.navigate "/#entries/#{date.year()}/#{date.month()+1}/#{date.date()}"
  key 'command+s', ->
    $("form button[type=submit]").trigger "click"
  _.map [0..9], (i) ->
    key "command+#{i}", ->
      Backbone.history.navigate "/#work_days/#{i}", true

