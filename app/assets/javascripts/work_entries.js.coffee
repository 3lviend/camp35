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

setupWorkCharts = ->
  if $("#work_entry_work_chart_id").length
    window.startSpinner()
    $.getJSON "/work_charts.json", (data) ->
      $("#work_entry_work_chart_id").optionTree(data) 
      window.stopSpinner()
               

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
