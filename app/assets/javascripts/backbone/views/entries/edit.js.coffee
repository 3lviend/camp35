TimesheetApp.Views.Entries ||= {}

class TimesheetApp.Views.Entries.EditView extends Backbone.View
  template: JST["backbone/templates/entries/edit"]
  selects_template: JST["backbone/templates/entries/_selects"]
  durations_template: JST["backbone/templates/entries/_durations"]

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
    @searches = new TimesheetApp.Collections.WorkChartsCollection()
    @searches.on "reset", @render_searches
    @duration_kinds = new TimesheetApp.Collections.DurationKindsCollection()
    @duration_kinds.on "reset", @render_durations
    @selected_chart = new TimesheetApp.Models.WorkChart()
    @selected_chart.on "change", =>
      @rebuild_charts_array_for(@selected_chart)
      @duration_kinds.url = "/work_charts/#{@selected_chart.get('id')}/duration_kinds.json"
      @duration_kinds.fetch()

  render_searches: =>
    lis = @searches.map (chart) ->
      "<li data-id='#{chart.get('id')}'>#{chart.get('labels')[1..10].join(' / ')}</li>"
    $(".search-results ul").html(lis.join("\n"))
    $(".search-results ul li").click @handle_quick_pick_option

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

  render_durations: =>
    data =
      work_entry:      @model.toJSON()
      duration_kinds:  @duration_kinds.toJSON()
    $(".durations").html @durations_template(data)
    $(".durations .hour-button").click (e) =>
      btn = $(e.currentTarget)
      hour = btn.attr("data-hour")
      $(".durations .hour-button").removeClass("selected")
      btn.addClass("selected")
      $(".durations .hour-select option").attr("selected", "")
      $(".durations .hour-select option[value=#{hour}]").attr("selected", "selected")
    $(".durations .hour-select").change (e) =>
      hour = $(e.currentTarget).val()
      $(".durations .hour-button").removeClass("selected")
      $(".durations .hour-button[data-hour=#{hour}]").addClass("selected")
    $(".durations .minutes-select").change (e) =>
      minutes = $(e.currentTarget).val()
      $(".durations .minute-button").removeClass("selected")
      $(".durations .minute-button[data-minute=#{minutes}]").addClass("selected")
    $(".durations .minute-button").click (e) =>
      btn = $(e.currentTarget)
      minutes = btn.attr("data-minute")
      $(".durations .minute-button").removeClass("selected")
      btn.addClass("selected")
      $(".durations .minutes-select option").attr("selected", "")
      $(".durations .minutes-select option[value=#{minutes}]").attr("selected", "selected")
    $(".durations .button.add:not(.disabled)").click =>
      durations = @model.get("work_entry_durations")
      last_duration = _.last(durations)
      new_duration = last_duration.constructor()
      new_duration.duration = "00:00:00"
      new_duration.modified_by = last_duration.modified_by
      new_duration.kind_code = _.first(@duration_kinds.filter( (k) => 
        return not _.include(_.pluck(durations, "kind_code"), k.get("code")) )
      ).get("code")
      durations.push(new_duration)
      @model.set("work_entry_durations", durations, silent: true)
      @render_durations()
      false
    $(".durations .button.remove:not(:disabled)").click (e) =>
      durations = @model.get("work_entry_durations")
      code = $(e.currentTarget).parents(".single-duration").find(".kind_code_select").val()
      durations = _.filter(durations, (d) -> d.kind_code != code)
      @model.set("work_entry_durations", durations, silent: true)
      @render_durations()
      false
    $(".durations .kind_code_select").change (e) =>
      durations = @model.get("work_entry_durations")
      index = parseInt $(e.currentTarget).attr("data-index")
      durations[index].kind_code = $(e.currentTarget).val()
      @model.set("work_entry_durations", durations, silent: true)
      @render_durations()
      false

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
    last_selected = _.last(_.filter(@charts, (arr) -> arr.length > 0)).find (chart) =>
      chart.get("selected") == true
    if last_selected
      @selected_chart.set("id", last_selected.get("id"), silent: true)
      @selected_chart.fetch()
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
    $("input.charts-search", @el).focus (e) =>
      $(".search-results", @el).show()
    $("input.charts-search", @el).blur => $(".search-results", @el).hide()
    $("input.charts-search", @el).keyup (e) =>
      $("input.charts-search", @el).stopTime("search")
      $("input.charts-search", @el).oneTime 500, "search", =>
        @searches.fetch
          data:
            $.param
              phrase: $("input.charts-search", @el).val()
    @render_durations()
    @selected_chart.set("id", @model.get("work_chart_id"), silent: true)
    @selected_chart.fetch()
    return this
