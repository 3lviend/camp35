TimesheetApp.Views.Reports ||= {}

class TimesheetApp.Views.Reports.ShowView extends Backbone.View
  template: JST["backbone/templates/reports/show"]
  controls_template: JST["backbone/templates/reports/controls"]

  initialize: =>
    @view = new TimesheetApp.Views.Reports.ShowViewModel()

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
    $("header .chosen").chosen()
    ko.applyBindings @view, $("header")[0]

class TimesheetApp.Views.Reports.ShowViewModel
  constructor: ->
    @report_types = ko.observableArray [
      {
        value:  "break"
        label:  "Break"
        active: true
      },
      {
        value:  "user"
        label:  "User"
        active: false
      },
      {
        value:  "category"
        label:  "Category"
        active: false
      }
    ]
    @select_type = (item) =>
      types = _.map @report_types(), (i) ->
        i.active = i.value == item.value
        i
      @report_types([])
      @report_types(types)
   
    @display_full = ko.observable false
    @printable    = ko.observable false
    @open_in_new  = ko.observable false


