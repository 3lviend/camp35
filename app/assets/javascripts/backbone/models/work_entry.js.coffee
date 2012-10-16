class TimesheetApp.Models.WorkEntry extends Backbone.Model
  defaults:
    date_created: new Date()
  url: =>
    "/work_entries/#{@id}.json"

class TimesheetApp.Collections.WorkEntriesCollection extends Backbone.Collection
  model: TimesheetApp.Models.WorkEntry
  url:   "/work_entries"
