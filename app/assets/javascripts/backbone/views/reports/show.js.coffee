TimesheetApp.Views.Reports ||= {}

class TimesheetApp.Views.Reports.ShowView extends Backbone.View
  template: JST["backbone/templates/reports/show"]
  controls_template: JST["backbone/templates/reports/controls"]

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

