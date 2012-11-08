class TimesheetApp.Models.WorkEntry extends Backbone.Model
  defaults:
    work_chart_id: -1
    work_entry_fees: []
    description: ""
    work_entry_durations: [
      duration: "00:00:00"
    ]
  url: =>
    "/work_entries/#{@id}.json"
  top_label: =>
    _.first _.rest(@get("work_chart_label_parts"))
  last_label: =>
    _.last @get("work_chart_label_parts")
  middle_labels: =>
   _.rest( _.rest( _.initial(@get("work_chart_label_parts")) ))

  hours: =>
    @get("total_duration").split(":")[0]

  minutes: =>
    @get("total_duration").split(":")[1]

  billable_hours: =>
    parseInt @get("total_billable").split(":")[0], 10

  billable_minutes: =>
    parseInt @get("total_billable").split(":")[1], 10

  nonbillable_hours: =>
    parseInt @get("total_nonbillable").split(":")[0], 10

  nonbillable_minutes: =>
    parseInt @get("total_nonbillable").split(":")[1], 10


  time_string: =>
    [hours, minutes] = @get("total_duration").split(":")
    "#{parseInt hours, 10}h #{parseInt minutes, 10}m"

  front_url: =>
    "/#entries/#{@get("id")}"


class TimesheetApp.Collections.WorkEntriesCollection extends Backbone.Collection
  model: TimesheetApp.Models.WorkEntry
  url:   "/work_entries"
