TimesheetApp.Views.Reports ||= {}

class TimesheetApp.Views.Reports.ShowView extends Backbone.View
  template: JST["backbone/templates/reports/show"]
  controls_template: JST["backbone/templates/reports/controls"]

  initialize: =>
    @view = new TimesheetApp.Views.Reports.ShowViewModel(@options.roles)

  render: ->
    $(@el).html(@template())
    $("#main").html @el

    $("header").html @controls_template()

    $('.daterange').daterangepicker
      ranges:
        "Today":       ["today", "today"]
        "Yesterday":   ["yesterday", "yesterday"]
        "Last 7 Days": [Date.today().add({ days: -6 }), 'today']
        'Last 30 Days': [Date.today().add({ days: -29 }), 'today']
        'This Month': [Date.today().moveToFirstDayOfMonth(), Date.today().moveToLastDayOfMonth()]
        'Last Month': [Date.today().moveToFirstDayOfMonth().add({ months: -1 }), Date.today().moveToFirstDayOfMonth().add({ days: -1 })]
    ko.applyBindings @view, $("header")[0]
    ko.applyBindings @view, $("#main")[0]

class TimesheetApp.Views.Reports.ShowViewModel
  constructor: (roles) ->
    @report_types = ko.observableArray [
      {
        value:  "break"
        label:  "Break"
        active: true
      }
    ]

    @select_type = (item) =>
      types = _.map @report_types(), (i) ->
        i.active = i.value == item.value
        i
      @report_types([])
      @report_types(types)

    @selected_type = ko.computed =>
      if @report_types().length == 0
        "break"
      else
        _.find @report_types(), (t) -> t.active
   
    @display_full = ko.observable false
    @printable    = ko.observable false
    @open_in_new  = ko.observable false
    @roles = ko.observableArray([])
    roles.on "reset", =>
      @roles(roles.models)
      $(window).oneTime 50, => $(".roles select").chosen()
    @date_range_string = ko.observable("")

    @generate_report = =>
      $.ajax
        url: "/reports/#{@selected_type().value}.json"
        data:
          start: @date_start().toDate()
          end:   @date_end().toDate()
          roles: @selected_roles()
        success: (items) => @report_items(items)

    @selected_roles = ko.observableArray([])

    @date_range = ko.computed =>
      @date_range_string().split(" - ")
    @date_start = ko.computed =>
      if @date_range().length == 2
        moment @date_range()[0]
      else
        null
    @date_end   = ko.computed =>
      if @date_range().length == 2
        moment @date_range()[1]
      else
        null

    @report_items = ko.observable()

    @ready_to_generate = ko.computed =>
      @date_range_string().trim() != "" && @selected_roles().length > 0

    @generate_status_class = ko.computed =>
      if @ready_to_generate()
        "button"
      else
        "button disabled"

