TimesheetApp.Views.Entries ||= {}

class TimesheetApp.Views.Entries.EditView extends Backbone.View
  template: JST["backbone/templates/entries/edit"]
  selects_template: JST["backbone/templates/entries/_selects"]
  durations_template: JST["backbone/templates/entries/_durations"]

  delete: =>
    if confirm "Are you sure you want to delete this entry?"
      date = moment.utc(@model.get("date_performed"))
      $.ajax
        url: "/work_day_entries/#{date.year()}/#{date.month()}/#{date.date()}/work_entries/#{@model.get('id')}"
        type: "DELETE"
        success: (data) =>
          if data.status == 'OK'
            humane.log "Entry deleted"
            @back()
          else
            humane.log data.errors
        error: (xhr, status, err)  =>
          humane.log err
    false


  back: =>
    date = moment.utc(@model.get("date_performed"), "ddd, YYYY-MM-DD")
    Backbone.history.navigate "entries/#{date.year()}/#{date.month() + 1}/#{date.date()}", true

  persist: =>
    @model.set "work_chart_id", @selected_chart.get("id"), silent: true
    @model.set "date_performed", $("#work_entry_date_performed").val(), silent: true
    @model.set "description", $("#work_entry_description").val(), silent: true
    durations = $(".single-duration").map (i, s) =>
      kind_code: $(".kind_code_select", s).val()
      duration_hours: $(".hour-select", s).val()
      duration_minutes: $(".minutes-select", s).val()
      created_by: @model.get('work_entry_durations')[0].created_by
      modified_by: @model.get('work_entry_durations')[0].created_by
      id: @model.get('work_entry_durations')[i].id
    @model.set "work_entry_durations", durations.toArray(), silent: true

    date = moment.utc(@model.get("date_performed"))

    data = @model.toJSON()
    data.work_entry_durations_attributes = data.work_entry_durations
    delete data.work_entry_durations

    $.ajax
      url: "/work_day_entries/#{date.year()}/#{date.month()}/#{date.date()}/work_entries/#{@model.get('id')}"
      type: "PUT"
      data:
        work_entry: data
      success: =>
        humane.log "Entry saved"
        @back()
      error: (xhr, status, err)  =>
        humane.log err
    false
 
  initialize: () ->
    @model.bind "change", @render
    @charts = []
    @charts[0] = new TimesheetApp.Collections.WorkChartsCollection()
    @charts[0].on "reset", @render_charts
    @show_inactive = false
    @frequents = new TimesheetApp.Collections.WorkChartsCollection()
    @frequents.url = "/work_charts/frequent.json"
    @frequents.on "reset", @render_frequents
    @recents = new TimesheetApp.Collections.WorkChartsCollection()
    @recents.url = "/work_charts/recent.json"
    @recents.on "reset", @render_recents
    @searches = new TimesheetApp.Collections.WorkChartsCollection()
    @searches.on "reset", @render_searches
    @duration_kinds = new TimesheetApp.Collections.DurationKindsCollection()
    @duration_kinds.on "reset", =>
      @render_durations()
      durations = @model.get("work_entry_durations")
      kinds = @duration_kinds.pluck("code")
      if @duration_kinds.size() < durations.length
        to_wipe = _.filter durations, (d) => not _.contains(kinds, d.kind_code)
        durations = _.difference durations, to_wipe
        [hours, minutes] = durations[0].duration.split(";")
        hours_to_add = _.map to_wipe, (d) ->
          parseInt d.duration.split(":")[0], 10
        minutes_to_add = _.map to_wipe, (d) ->
          parseInt d.duration.split(":")[1], 10
        new_hours = (parseInt hours, 10) + _.reduce(hours_to_add, ((s, i) -> s + i), 0)
        new_minutes = (parseInt minutes, 10) + _.reduce(minutes_to_add, ((s, i) -> s + i), 0)
        durations[0].duration = "#{new_hours}:#{new_minutes}:00"
        @model.set("work_entry_durations", durations, silent: true)
        @render_durations()

    @selected_chart = new TimesheetApp.Models.WorkChart()
    @selected_chart.on "change", =>
      @rebuild_charts_array_for(@selected_chart)
      @duration_kinds.url = "/work_charts/#{@selected_chart.get('id')}/duration_kinds.json"
      @duration_kinds.fetch()

  set_duration_hour: (index, hour) =>
    durations = @model.get("work_entry_durations")
    d = durations[index].duration
    [_hour, minute] = d.split(":")
    durations[index].duration = "#{hour}:#{minute}:00"
    @model.set("work_entry_durations", durations, silent: true)

  set_duration_minutes: (index, minute) =>
    durations = @model.get("work_entry_durations")
    d = durations[index].duration
    [hour, _minute] = d.split(":")
    durations[index].duration = "#{hour}:#{minute}:00"
    @model.set("work_entry_durations", durations, silent: true)

  render_searches: =>
    lis = @searches.map (chart) ->
      "<li data-id='#{chart.get('id')}'>#{chart.get('labels')[1..10].join(' / ')}</li>"
    $(".search-results ul").html(lis.join("\n"))
    $(".search-results ul li").click @handle_quick_pick_option

  render_frequents: =>
    clients = @frequents.filter (chart) ->
      chart.get('labels').length > 3 && chart.get('labels')[1] == "Clients"
    others = @frequents.filter (chart) ->
      chart.get('labels').length < 3 || chart.get('labels')[1] != "Clients"
    clis = _.sortBy(clients, (c) -> c.get("labels")[2]).map (chart) ->
      "<li data-id='#{chart.get('id')}'>#{chart.get('labels')[2..10].join(' / ')}</li>"
    olis = _.sortBy(others, (c) -> c.get("labels")[1]).map (chart) ->
      "<li data-id='#{chart.get('id')}'>#{chart.get('labels')[1..10].join(' / ')}</li>"
    $(".frequent ul.clients").html(clis.join("\n"))
    $(".frequent ul.other").html(olis.join("\n"))
    $(".frequent ul li").click @handle_quick_pick_option

  render_recents: =>
    clients = @recents.filter (chart) ->
      chart.get('labels').length > 3 && chart.get('labels')[1] == "Clients"
    others = @recents.filter (chart) ->
      chart.get('labels').length < 3 || chart.get('labels')[1] != "Clients"
    clis = _.sortBy(clients, (c) -> c.get("labels")[2]).map (chart) ->
      "<li data-id='#{chart.get('id')}'>#{chart.get('labels')[2..10].join(' / ')}</li>"
    olis = _.sortBy(others, (c) -> c.get("labels")[1]).map (chart) ->
      "<li data-id='#{chart.get('id')}'>#{chart.get('labels')[1..10].join(' / ')}</li>"
    $(".recent ul.clients").html(clis.join("\n"))
    $(".recent ul.other").html(olis.join("\n"))
    $(".recent ul li").click @handle_quick_pick_option

  render_durations: =>
    data =
      work_entry:      @model.toJSON()
      duration_kinds:  @duration_kinds.toJSON()
    $(".durations").html @durations_template(data)
    $(".durations .hour-button").click (e) =>
      btn = $(e.currentTarget)
      div = $(e.currentTarget).parents(".single-duration")
      hour = btn.attr("data-hour")
      $(" .hour-button", div).removeClass("selected")
      btn.addClass("selected")
      $(" .hour-select option", div).attr("selected", "")
      $(" .hour-select option[value=#{hour}]", div).attr("selected", "selected")
      index = parseInt $(e.currentTarget).attr("data-index"), 10
      @set_duration_hour(index, hour)
      false
    $(" .hour-select").change (e) =>
      hour = $(e.currentTarget).val()
      div = $(e.currentTarget).parents(".single-duration")
      $(" .hour-button", div).removeClass("selected")
      $(" .hour-button[data-hour=#{hour}]", div).addClass("selected")
      index = parseInt $(e.currentTarget).attr("data-index"), 10
      @set_duration_hour(index, hour)
      false
    $(" .minutes-select").change (e) =>
      minutes = $(e.currentTarget).val()
      div = $(e.currentTarget).parents(".single-duration")
      $(" .minute-button", div).removeClass("selected")
      $(" .minute-button[data-minute=#{minutes}]", div).addClass("selected")
      index = parseInt $(e.currentTarget).attr("data-index"), 10
      @set_duration_minutes(index, minutes)
    $(" .minute-button").click (e) =>
      btn = $(e.currentTarget)
      div = $(e.currentTarget).parents(".single-duration")
      minutes = btn.attr("data-minute")
      $(" .minute-button", div).removeClass("selected")
      btn.addClass("selected")
      $(" .minutes-select option", div).attr("selected", "")
      $(" .minutes-select option[value=#{minutes}]", div).attr("selected", "selected")
      index = parseInt $(e.currentTarget).attr("data-index"), 10
      @set_duration_minutes(index, minutes)
      false
    $(" .button.add:not(.disabled)").click =>
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
      index = parseInt $(e.currentTarget).attr("data-index"), 10
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
      charts: @charts.map (charts) =>
        if @show_inactive
          charts.toJSON()
        else
          _.map charts.where(status: "active"), (c) -> c.toJSON()
      entry: @model.toJSON()
    $(".chart-selects", @el).html(@selects_template(data)) 
    $(".chart-selects select").change (e) =>
      val = parseInt $(e.currentTarget).val(), 10
      level = parseInt $(e.currentTarget).attr("data-level"), 10
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
    $("section[role=main]").html("")
    $(@el).html(@template(@model.toJSON()))
    $("textarea", @el).autoGrow()
    $(".calendar", @el).datepicker
      dateFormat: "DD, yy-mm-dd"
    $(".calendar", @el).datepicker "setDate", moment.utc(@model.get('date_performed')).format("dddd, YYYY-MM-DD")
    $("#main").html(@el)
    $("#side").html ""
    $("header").html("<h1>Edit entries for #{moment.utc(@model.get('date_performed')).format("LL")}</h1><h4>Edit entry for the work you're doing at End Point</h4>")
    @charts[0].fetch
      data:
        $.param
          parent_id: 2
    $(".dropdown", @el).click (e) =>
      $("html").click => $(".no-hover", @el).removeClass("shown")
      $(".no-hover", @el).toggleClass "shown"
      e.stopPropagation()
    $(".toggle_charts_filter").click (e) =>
      @show_inactive = not @show_inactive
      @render_charts()
      label = if @show_inactive then "Hide inactive" else "Show inactive"
      $(e.currentTarget).html label
      false
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
    $("a.alert", @el).click (e) =>
      @delete()
      false
    $("button[type=submit]", @el).click (e) =>
      @persist()
      e.preventDefault()
    return this
