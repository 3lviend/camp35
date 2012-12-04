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

  chart_has_many_labels: =>
    @get("work_chart_label_parts").length > 2

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
    @get("total_duration").format_interval()

  fee_total_string: =>
    @get("fee_total").format_money()

  fee_not_empty: =>
    @get("fee_total") > 0

  front_url: =>
    "/#entries/#{@get("id")}"


class TimesheetApp.Collections.WorkEntriesCollection extends Backbone.Collection
  model: TimesheetApp.Models.WorkEntry
  url:   "/work_entries"
