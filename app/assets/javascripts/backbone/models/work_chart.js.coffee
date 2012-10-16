class TimesheetApp.Models.WorkChart extends Backbone.Model
  url: =>
    "/work_charts/#{@id}.json"

class TimesheetApp.Collections.WorkChartsCollection extends Backbone.Collection
  model: TimesheetApp.Models.WorkChart
  url:   "/work_charts"
