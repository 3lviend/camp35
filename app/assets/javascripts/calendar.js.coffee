
jumpToToday = ->
  today = window.today
  Turbolinks.visit "/work_day_entries/#{today.getUTCDate()}/#{today.getMonth() + 1}/#{today.getFullYear()}"

$ ->
  setupCalendar()
  document.addEventListener("page:change", ->
    setupCalendar())

setupCalendar = ->
  # naive for now data set:
  years = [2012, 2011, 2010, 2009, 2008, 2007, 2006]
  months = [12,11,10,9,8,7,6,5,4,3,2,1]
  days = [30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1]

  window.years = years
  window.months = months
  window.days = days

  today = new Date($("body").attr("data-today"))
  is_week = false
  window.today = today

  calendar = d3.select("#calendar-widget").append("svg")
    .attr("class", "calendar") 
    .attr("width", 70)
    .attr("height", 1000)

  calendar.append("line")
    .attr("x1", 11)
    .attr("x2", 11)
    .attr("y1", 0)
    .attr("y2", 1000)
    .attr("stroke", "#2BA6CB")

  calendar.append("line")
    .attr("x1", 35)
    .attr("x2", 35)
    .attr("y1", 0)
    .attr("y2", 1000)
    .attr("stroke", "#2BA6CB")

  if !is_week
    calendar.append("line")
      .attr("x1", 59)
      .attr("x2", 59)
      .attr("y1", 0)
      .attr("y2", 1000)
      .attr("stroke", "#2BA6CB")

  calendar.selectAll("circle.year")
    .data(years)
  .enter().append("circle")
    .attr("class", "year")
    .attr("cx", 11)
    .attr("cy", (d) -> 30*years.indexOf(d) + 20)
    .attr("r", 10)
    .attr("fill", (d) ->  if d == today.getFullYear()
         "#2BA6CB" 
       else
         "#fff")
    .attr("stroke", "#2BA6CB")
    .attr("cursor", "pointer")

  calendar.selectAll("text.year")
    .data(years)
  .enter().append("text")
    .attr("class", "year")
    .attr("x", 2.5)
    .attr("y", (d) -> 30*years.indexOf(d) + 25)
    .attr("fill", (d) ->  if d == today.getFullYear()
         "#fff" 
       else
         "#2BA6CB")
    .attr("font-family", "OpenSansLight")
    .text( (d) -> d.toString()[-2..-1])

  calendar.selectAll("circle.month")
    .data(months)
  .enter().append("circle")
    .attr("class", "month")
    .attr("cx", 35)
    .attr("cy", (d) -> 30*months.indexOf(d) + 20)
    .attr("r", 10)
    .attr("stroke", "#2BA6CB")
    .attr("fill", "#fff")
    .attr("fill", (d) ->  if d - 1 == today.getMonth()
         "#2BA6CB" 
       else
         "#fff")
    .attr("cursor", "pointer")

  calendar.selectAll("text.month")
    .data(months)
  .enter().append("text")
    .attr("class", "month")
    .attr("x", 26.5)
    .attr("y", (d) -> 30*months.indexOf(d) + 25)
    .attr("fill", "#2BA6CB")
    .attr("fill", (d) ->  if d - 1 == today.getMonth()
         "#fff" 
       else
         "#2BA6CB")
    .attr("font-family", "OpenSansLight")
    .text( (d) -> 
      lead = ""
      lead = "0" if d < 10
      lead + d.toString()[-2..-1])

  if !is_week
    calendar.selectAll("circle.day")
      .data(days)
    .enter().append("circle")
      .attr("class", "day")
      .attr("cx", 59)
      .attr("cy", (d) -> 30*days.indexOf(d) + 20)
      .attr("r", 10)
      .attr("stroke", "#2BA6CB")
      .attr("fill", "#fff")
      .attr("fill", (d) ->  if d  == today.getUTCDate()
           "#2BA6CB" 
         else
           "#fff")
      .attr("cursor", "pointer")

    calendar.selectAll("text.day")
      .data(days)
    .enter().append("text")
      .attr("class", "day")
      .attr("x", 50.5)
      .attr("y", (d) -> 30*days.indexOf(d) + 25)
      .attr("fill", "#2BA6CB")
      .attr("fill", (d) ->  if d  == today.getUTCDate()
           "#fff" 
         else
           "#2BA6CB")
      .attr("font-family", "OpenSansLight")
      .text( (d) -> 
        lead = ""
        lead = "0" if d < 10
        lead + d.toString()[-2..-1])

  window.calendar = calendar

  $(".day").click (e) ->
    t = e.target.textContent
    t = t[1..1] if t.length == 2 and t[0] == "0"
    window.today.setUTCDate(parseInt(t))
    window.calendar.selectAll("circle.day")
      .attr("fill", (d) ->  if d  == window.today.getUTCDate()
         "#2BA6CB" 
       else
         "#fff")
    window.calendar.selectAll("text.day")
      .attr("fill", (d) ->  if d  == window.today.getUTCDate()
         "#fff" 
       else
         "#2ba6cb")
    jumpToToday()

  $(".month").click (e) ->
    t = e.target.textContent
    t = t[1..1] if t.length == 2 and t[0] == "0"
    window.today.setMonth(parseInt(t) - 1)
    window.calendar.selectAll("circle.month")
      .attr("fill", (d) ->  if d - 1 == window.today.getMonth()
         "#2BA6CB" 
       else
         "#fff")
    window.calendar.selectAll("text.month")
      .attr("fill", (d) ->  if d - 1 == window.today.getMonth()
         "#fff" 
       else
         "#2ba6cb")
    jumpToToday()

   $(".year").click (e) ->
    t = e.target.textContent
    window.today.setFullYear(parseInt("20" + t))
    window.calendar.selectAll("circle.year")
      .attr("fill", (d) ->  if d  == window.today.getFullYear()
         "#2BA6CB" 
       else
         "#fff")
    window.calendar.selectAll("text.year")
      .attr("fill", (d) ->  if d == window.today.getFullYear()
         "#fff" 
       else
         "#2ba6cb")      
    jumpToToday()
