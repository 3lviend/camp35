# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

set_kinds_visibility = () ->
    data = $(".kind_code_select option")
    if data.length < 2
      $(".kind_code_select").parents("div.input").css("visibility", "hidden")
    else 
      $(".kind_code_select").parents("div.input").css("visibility", "visible")

update_kinds = (work_chart_id) ->
  $.getJSON "/work_charts/#{work_chart_id}/duration_kinds.json", (data) ->
    # here we have an array of objects in data
    value = $(".kind_code_select").val()
    $(".kind_code_select").html("")
    for kind in data
      $(".kind_code_select").append "<option value='#{kind.code}'>#{kind.display_label}</option>"
    $(".kind_code_select").val(value)
    $(".kind_code_select").trigger("liszt:updated")
    set_kinds_visibility()

setupKinds = ->
  # whenever work_entry_work_chart_id gets changed we need to
  # to update select with duration kinds
  $("#work_entry_work_chart_id").change (e) ->
    work_chart_id = $(e.currentTarget).val()
    update_kinds(work_chart_id)
  work_chart_id = $("#work_entry_work_chart_id").val()
  update_kinds(work_chart_id) if work_chart_id
  set_kinds_visibility()

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

setupChosen = ->
  $(".work_chart_selector .chzn-container").remove()
  $(".work_chart_selector .chzn-done").removeClass("chzn-done")
  $(".work_chart_selector select").chosen().change (e) ->
    $(window).oneTime 200,  ->
      setupChosen()
      # now if last added select has value of undefined
      # focus it's search field
      last_select = $(".work_chart_selector select").last()[0]
      if last_select && last_select != e.currentTarget
        $(last_select).next('.chzn-container').trigger('mousedown')
  $("select").chosen()
      

setupRegularWidget = (data) ->
      $("#work_entry_work_chart_id").optionTree data,
        preselect: { "work_entry[work_chart_id]": get_chart_path(data, $("#work_entry_work_chart_id").val(), []) } 
        choose: ""
      window.stopSpinner()
      setupChosen()


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
    
setupIntervals = ->
  $(".hour-button").live "click", (e) ->
    hour = $(e.currentTarget).attr("data-hour")
    $($(e.currentTarget).parents(".interval").find("select")[0]).val(hour).trigger("liszt:updated")
    $(e.currentTarget).parents(".interval").find(".hour-button").removeClass("selected")
    $(e.currentTarget).addClass("selected")
    false

  $(".minute-button").live "click", (e) ->
    minute = $(e.currentTarget).attr("data-minute")
    $($(e.currentTarget).parents(".interval").find("select")[1]).val(minute).trigger("liszt:updated")
    $(e.currentTarget).parents(".interval").find(".minute-button").removeClass("selected")
    $(e.currentTarget).addClass("selected")
    false

  $("div.interval").each (i, div) ->
    val = parseInt($($(div).find("select")[0]).val())
    $("a[data-hour=#{val}]", div).click()
    val = parseInt($($(div).find("select")[1]).val())
    $("a[data-minute=#{val}]", div).click()
 
  $(".button.add").click (e) ->
    new_el_html = $($(".durations .single-duration").last()).clone().wrap('<div>').parent().html()
    reg = /]\[\d\]/
    index = reg.exec(new_el_html)[0]
    index = parseInt(index.split("[")[1])
    new_el_html = new_el_html.replace(new RegExp("\\[" + index, "g"), "[" + (index + 1)).replace(new RegExp("_#{index}_", "g"), "_#{index+1}_")
    console.log new_el_html
    $(".durations").append(new_el_html)
    $(".durations .chzn-container").remove()
    $(".durations .chzn-done").removeClass("chzn-done")
    $(".durations select").chosen()
    false

$ ->
  setupKinds()
  setupWorkCharts()
  setupIntervals()
  $(document).bind "page:change", ->
    setupKinds()
    setupWorkCharts()
    setupIntervals()
