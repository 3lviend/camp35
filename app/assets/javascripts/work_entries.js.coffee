# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

update_kinds = (work_chart_id) ->
  $.getJSON "/work_charts/#{work_chart_id}/duration_kinds.json", (data) ->
    # here we have an array of objects in data
    $(".kind_code_select").html("")
    for kind in data
      $(".kind_code_select").append "<option value='#{kind.code}'>#{kind.display_label}</option>"

setupKinds = ->
  work_chart_id = $("#work_entry_work_chart_id").val()
  update_kinds(work_chart_id) if work_chart_id

# Tree WorkChart -> Maybe Int -> [String]
get_chart_path = (data, _id, parents) ->
  return [] unless _id
  id = parseInt _id
  for branch of data
    if typeof(data[branch]) == "number"
      if parseInt(data[branch]) == id
        return parents.concat([branch])
    else
      path = get_chart_path data[branch], id, parents.concat([branch])
      return parents.concat(path) if path.length - parents.length > 1
  return parents.concat([])

setupRegularWidget = (data) ->
      $("#work_entry_work_chart_id").optionTree data,
        preselect: { "work_entry[work_chart_id]": get_chart_path(data, $("#work_entry_work_chart_id").val(), []) } 
      window.stopSpinner()

setupRegularWorkCharts = ->
  if window.work_charts
    setupRegularWidget window.work_charts
  else
    window.startSpinner()
    $.getJSON "/work_charts.json", (data) ->
      window.work_charts = data
      setupRegularWidget data

setupWorkCharts = ->
  if $("#work_entry_work_chart_id").length
    setupRegularWorkCharts()
  $(".quick-pick").click (e) ->
    id = $(e.currentTarget).attr("data-id")
    $("#work_entry_work_chart_id").val(id)
    setupRegularWorkCharts()
    
               

$ ->
  # whenever work_entry_work_chart_id gets changed we need to
  # to update select with duration kinds
  $("#work_entry_work_chart_id").change (e) ->
    work_chart_id = $(e.currentTarget).val()
    update_kinds(work_chart_id)
  # also - make sure we get a proper kind at load
  setupKinds()
  setupWorkCharts()
  $(document).bind "page:change", ->
    setupKinds()
    setupWorkCharts()
