TimesheetApp.Views.Entries ||= {}

class TimesheetApp.Views.Entries.EditView extends Backbone.View
  template: JST["backbone/templates/entries/edit"]
  selects_template: JST["backbone/templates/entries/_selects"]

  initialize: () ->
    @model.bind "change", @render
    @charts = []
    @charts[0] = new TimesheetApp.Collections.WorkChartsCollection()
    @charts[0].on "reset", @render_charts

  render_charts: =>
    data = 
      charts: @charts.map (charts) ->
        charts.toJSON()
      entry: @model.toJSON()
    $(".chart-selects", @el).html(@selects_template(data)) 
    $(".chart-selects select").change (e) =>
      val = parseInt $(e.currentTarget).val()
      level = parseInt $(e.currentTarget).attr("data-level")
      num = level + 1
      @charts = @charts[0..level]
      chart = @charts[level].get(val)
      @charts[level].each (c) ->
        c.set("selected", false)
      chart.set("selected", true)
      console.info chart
      @charts[num] = new TimesheetApp.Collections.WorkChartsCollection()
      @charts[num].on "reset", @render_charts
      @charts[num].fetch
        data:
          $.param
            parent_id: val

  render: =>
    $(@el).html(@template(@model.toJSON()))
    $("textarea", @el).autoGrow()
    $(".calendar", @el).datepicker
      dateFormat: "yy-mm-dd"
    $("#main").html(@el)
    $("header").html("<h1>Edit entries for #{@model.get('date_performed')}</h1>")
    @charts[0].fetch 
      data:
        $.param
          parent_id: 2
    return this
