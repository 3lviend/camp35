Router           = require 'routers/router'

Role            = require 'models/role'
RolesCollection = require 'collections/roles'

TopBarView       = require 'views/navigation/top_bar'
SwitchRoleView   = require 'views/admin/switch_role'
ReportsView      = require 'views/reports'
LogInView        = require 'views/auth/login'
CalendarView     = require 'views/calendar'
EntryNewView     = require 'views/entries/new'
EntryEditView    = require 'views/entries/edit'
WorkDayView      = require 'views/work_day'

Modal            = require 'lib/modal_window.js'

module.exports = class Application

  constructor: ->
    $ =>
      @initialize()
      Backbone.history.start()

  initialize: ->
    @current_role = new Role
    @current_role.url = "/roles/current.json"
    @current_role.fetch()
    @rolesToSwitch = new RolesCollection
    @rolesToSwitch.url = "/roles/others.json"
    @rolesToReport = new RolesCollection
    @rolesToReport.url = "/roles/reportable.json"

    @router         = new Router
    @topBarView     = new TopBarView role: @current_role
    @switchRoleView = new SwitchRoleView other_roles: @rolesToSwitch
    @reportsView    = new ReportsView roles: @rolesToReport
    @loginView      = new LogInView
    # @calendarView   = new CalendarView
    # @entryNewView   = new EntryNewView
    # @entryEditView  = new EntryEditView
    # @workDayView    = new WorkDayView

    @modal          = new Modal("#modal")

    $(document).foundationTopBar()


window.app = new Application


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
      window.app.router.navigate "/#login", trigger:true
    403: ->
      window.app.router.navigate "/#denied", trigger:true
      $("#today, #new_entry, #logout, #this_month").hide()

$(document).ajaxStop stopSpinner

$(document).ajaxStart ->
  startSpinner()

$(document).oneTime 200, ->
  humane.timeout = 1000


