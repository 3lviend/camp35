class TimesheetApp.Routers.MainRouter extends Backbone.Router
  routes :
    '': 'root'
    'login': 'login'
    'calendar/:year/:month': 'home'
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
      date = moment.utc(new Date())
      window.location.href = "/#calendar/#{date.year()}/#{date.month() + 1}"

  home: (year, month) ->
    days = new TimesheetApp.Collections.WorkDaysCollection()
    days.url = "/work_days/calendar/#{year}/#{month}.json"
    view = new TimesheetApp.Views.Home.IndexView(collection: days, year: year, month: month)
    days.fetch()

  new_entry: (year, month, day) ->
    day = moment.utc([year, month-1, day]).format("YYYY-MM-DD")
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
      $("#today, #new_entry, #logout, #this_month").hide()
      window.location.replace "/#login"
    403: ->
      window.location.replace "/#denied"
      $("#today, #new_entry, #logout, #this_month").hide()

$(document).ajaxStop stopSpinner

$(document).ajaxStart ->
  startSpinner()

$(document).oneTime 200, ->
  humane.timeout = 1000
  $("#today").click ->
    now = moment.utc(new Date())
    Backbone.history.navigate "/#entries/#{now.year()}/#{now.month() + 1}/#{now.date()}", true
    false

  $("#this_month").click ->
    now = moment.utc(new Date())
    Backbone.history.navigate "/#calendar/#{now.year()}/#{now.month() + 1}", true
    false

  $("#new_entry").click ->
    now = moment.utc(new Date())
    Backbone.history.navigate "/#entries/#{now.year()}/#{now.month() + 1}/#{now.date()}/new", true
    false

  $("#admin").click ->
    window.location.replace "/admin"
    false

  $("#logout").click ->
    $.ajax
      url: "/users/sign_out"
      type: "DELETE"
      success: =>
        humane.log "Goodbye"
        $("#logout").hide()
        Backbone.history.navigate "/#", true
      error: =>
        # humane.log "Something wrong happened.. Please contact admin"
        # kinda nasty workaround... TODO: fix
        humane.log "Goodbye"
        $("#logout").hide()
        Backbone.history.navigate "/#", true
    false

$ ->
  key 'command+n', ->
    date = moment.utc()
    Backbone.history.navigate "/#entries/#{date.year()}/#{date.month()+1}/#{date.date()}/new", true
  key 'command+t', ->
    date = moment.utc()
    Backbone.history.navigate "/#entries/#{date.year()}/#{date.month()+1}/#{date.date()}"
  key 'command+s', ->
    $("form button[type=submit]").trigger "click"
  _.map [0..9], (i) ->
    key "command+#{i}", ->
      Backbone.history.navigate "/#work_days/#{i}", true

