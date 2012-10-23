class TimesheetApp.Routers.MainRouter extends Backbone.Router
  routes :
    'calendar': 'home'
    'entries/:id': 'edit_entry'
    'work_days/:weeks_from_now': 'work_days'

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
