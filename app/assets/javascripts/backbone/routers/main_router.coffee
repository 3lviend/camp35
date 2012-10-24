class TimesheetApp.Routers.MainRouter extends Backbone.Router
  routes :
    'calendar': 'home'
    'entries/:id': 'edit_entry'
    'work_days/:weeks_from_now': 'work_days'
    'entries/:year/:month/:day': 'work_day'

  home: ->
    view = new TimesheetApp.Views.Home.IndexView()
    $(window).oneTime 100, () => @view.render()

  edit_entry: (id) ->
    entry = new TimesheetApp.Models.WorkEntry(id: id)
    view = new TimesheetApp.Views.Entries.EditView(model: entry, charts: @work_charts)
    entry.fetch()

  work_days: (weeks_from_now) ->
    days = new TimesheetApp.Collections.WorkDaysCollection()
    view = new TimesheetApp.Views.WorkDays.IndexView(collection: days, weeks_from_now: weeks_from_now)
    days.url = "/work_days/#{weeks_from_now}.json"
    days.fetch()

  work_day: (year, month, day) ->
    entries = new TimesheetApp.Collections.WorkEntriesCollection()
    view = new TimesheetApp.Views.WorkEntries.IndexView(collection: entries, year: year, month: month, day: day)
    entries.url = "/work_day_entries/#{year}/#{month}/#{day}.json"
    entries.fetch()

