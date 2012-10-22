TimesheetApp.Views.Home ||= {}

class TimesheetApp.Views.Home.IndexView extends Backbone.View
  template: JST["backbone/templates/home/index"]

  initialize: () ->
    console.info ""

  render: () ->
    $(@el).html(@template())
    $("section[role=main]").html(@el)
