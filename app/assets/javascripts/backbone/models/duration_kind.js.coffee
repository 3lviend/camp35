class TimesheetApp.Models.DurationKind extends Backbone.Model
  url: =>
    "/work_charts//duration_kinds.json"

class TimesheetApp.Collections.DurationKindsCollection extends Backbone.Collection
  model: TimesheetApp.Models.DurationKind
  url:   "/work_charts//duration_kinds.json"
