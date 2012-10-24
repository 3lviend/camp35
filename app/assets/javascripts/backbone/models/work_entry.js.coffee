class TimesheetApp.Models.WorkEntry extends Backbone.Model
  defaults:
    date_created: new Date()
  url: =>
    "/work_entries/#{@id}.json"
  top_label: =>
    _.first _.rest(@get("work_chart_label_parts"))
  last_label: =>
    _.last @get("work_chart_label_parts")
  middle_labels: =>
    _.rest _.initial(@get("work_chart_label_parts"))

  time_string: =>
    [hours, minutes] = @get("total_duration").split(":")
    "#{parseInt hours}h #{parseInt minutes}m"

  front_url: =>
    "/#entries/#{@get("id")}"


class TimesheetApp.Collections.WorkEntriesCollection extends Backbone.Collection
  model: TimesheetApp.Models.WorkEntry
  url:   "/work_entries"
