class TimesheetApp.Routers.MainRouter extends Backbone.Router
  routes :
    '': 'home'
    'entries/:id': 'edit_entry'

  home: ->
    @view = new TimesheetApp.Views.Home.IndexView()
    $(window).oneTime 100, () => @view.render()

  edit_entry: (id) ->
    entry = new TimesheetApp.Models.WorkEntry(id: id)
    @view = new TimesheetApp.Views.Entries.EditView(model: entry, charts: @work_charts)
    entry.fetch()
