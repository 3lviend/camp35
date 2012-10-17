TimesheetApp.Views.Entries ||= {}

class TimesheetApp.Views.Entries.EditView extends Backbone.View
  template: JST["backbone/templates/entries/edit"]
  selects_template: JST["backbone/templates/entries/_selects"]

  initialize: () ->
    @model.bind "change", @render
    @charts = []
    @charts[0] = new TimesheetApp.Collections.WorkChartsCollection()
    @charts[0].on "reset", @render_charts
    @frequents = new TimesheetApp.Collections.WorkChartsCollection()
    @frequents.url = "/work_charts/frequent.json"
    @frequents.on "reset", @render_frequents
    @recents = new TimesheetApp.Collections.WorkChartsCollection()
    @recents.url = "/work_charts/recent.json"
    @recents.on "reset", @render_recents

  render_frequents: =>
    lis = @frequents.map (chart) ->
      "<li data-id='#{chart.get('id')}'>#{chart.get('labels')[1..10].join(' / ')}</li>"
    $(".frequent ul").html(lis.join("\n"))
    $(".frequent ul li").click @handle_quick_pick_option

  render_recents: =>
    lis = @recents.map (chart) ->
      "<li data-id='#{chart.get('id')}'>#{chart.get('labels')[1..10].join(' / ')}</li>"
    $(".recent ul").html(lis.join("\n"))
    $(".recent ul li").click @handle_quick_pick_option

  handle_quick_pick_option: (e) =>
    chart_id = $(e.currentTarget).attr("data-id")
    chart = new TimesheetApp.Models.WorkChart(id: chart_id)
    chart.bind "change", => @rebuild_charts_array_for chart
    chart.fetch()
    
  # it builds a charts array in a reverse order based 
  # on leaf id
  rebuild_charts_array_for: (chart) =>
    
    _rebuild_array = (chart) =>
      if chart.get("parent_id") == 1
        @render_charts()
        return
      new_collection = new TimesheetApp.Collections.WorkChartsCollection()
      @charts.unshift new_collection
      new_collection.on "reset", =>
        c = new_collection.get(chart.get("id"))
        c.set("selected", true) if c
        parent = new TimesheetApp.Models.WorkChart(id: chart.get("parent_id"))
        parent.bind "change", => _rebuild_array parent
        parent.fetch()
      new_collection.fetch
        data:
          $.param
            parent_id: chart.get("parent_id")
            include_inactive: true

    @charts = []
    _rebuild_array chart

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
    $(".dropdown", @el).click (e) =>
      $("html").click => $(".no-hover", @el).removeClass("shown")
      $(".no-hover", @el).toggleClass "shown"
      e.stopPropagation()
    @frequents.fetch()
    @recents.fetch()
    return this
